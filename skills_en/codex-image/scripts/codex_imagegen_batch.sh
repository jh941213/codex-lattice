#!/usr/bin/env bash
# codex_imagegen_batch.sh
# Codex CLI 의 image_generation 툴로 이미지를 5개씩 병렬 배치 생성한다.
#
# Usage:
#   codex_imagegen_batch.sh <work_dir> "프롬프트1::output1.png" "프롬프트2::output2.png" ...
#
# 동작:
#   - 입력 N개를 받아 최대 5개씩 묶어 동시 실행
#   - 한 배치가 끝나야 다음 배치 시작
#   - 각 작업 결과 PNG 는 <work_dir>/ 에 저장
#   - codex 최종 메시지는 <work_dir>/.codex-imagegen-logs/<n>.md 에 보관

set -u
set -o pipefail

readonly MAX_PARALLEL=5

usage() {
  cat >&2 <<'EOF'
Usage: codex_imagegen_batch.sh <work_dir> "prompt1::out1.png" "prompt2::out2.png" ...

Each item must be in the form  "<prompt>::<output_filename>".
Output filenames must be unique. Up to 5 items run in parallel; remaining
items run in subsequent batches of 5.

Example:
  codex_imagegen_batch.sh ./out \
    "A red apple on white::apple.png" \
    "A blue mug::mug.png" \
    "A green plant::plant.png"
EOF
  exit 1
}

[ $# -lt 2 ] && usage

WORK_DIR="$1"
shift

if [ ! -d "$WORK_DIR" ]; then
  echo "[error] work_dir not found: $WORK_DIR" >&2
  exit 2
fi

WORK_DIR="$(cd "$WORK_DIR" && pwd)"
LOG_DIR="$WORK_DIR/.codex-imagegen-logs"
mkdir -p "$LOG_DIR"

if ! command -v codex >/dev/null 2>&1; then
  echo "[error] codex CLI not found in PATH" >&2
  exit 3
fi

if ! codex login status >/dev/null 2>&1; then
  echo "[error] codex not logged in. run: codex login" >&2
  exit 4
fi

# Collect items
declare -a PROMPTS=()
declare -a OUTPUTS=()
seen_outputs=" "
n=0
for item in "$@"; do
  if [[ "$item" != *"::"* ]]; then
    echo "[error] item missing '::' separator: $item" >&2
    exit 5
  fi
  prompt="${item%%::*}"
  output="${item#*::}"
  if [ -z "$prompt" ] || [ -z "$output" ]; then
    echo "[error] empty prompt or output: $item" >&2
    exit 6
  fi
  if [[ "$seen_outputs" == *" $output "* ]]; then
    echo "[error] duplicate output filename: $output" >&2
    exit 7
  fi
  seen_outputs="$seen_outputs$output "
  PROMPTS[$n]="$prompt"
  OUTPUTS[$n]="$output"
  n=$((n+1))
done

TOTAL=$n
echo "[info] work_dir: $WORK_DIR"
echo "[info] total jobs: $TOTAL"
echo "[info] parallelism: up to $MAX_PARALLEL per batch"
echo

run_one() {
  local idx="$1"
  local prompt="$2"
  local output="$3"
  local log="$LOG_DIR/$(printf '%03d' "$idx").md"

  codex exec \
    --sandbox workspace-write \
    --skip-git-repo-check \
    --cd "$WORK_DIR" \
    -o "$log" \
    "이미지 생성 도구로 '$prompt' 이미지를 생성하고 ./$output 로 저장. 파일 경로만 한 줄로 보고." \
    >"$LOG_DIR/$(printf '%03d' "$idx").stdout" 2>&1
  local rc=$?
  if [ $rc -eq 0 ] && [ -f "$WORK_DIR/$output" ]; then
    echo "  [ok]  #$idx  $output  ($(wc -c <"$WORK_DIR/$output" | tr -d ' ') bytes)"
  else
    echo "  [FAIL] #$idx  $output  (rc=$rc)"
  fi
  return $rc
}

batch_start=0
batch_no=1
overall_start=$(date +%s)

while [ $batch_start -lt $TOTAL ]; do
  batch_end=$((batch_start + MAX_PARALLEL))
  [ $batch_end -gt $TOTAL ] && batch_end=$TOTAL
  batch_size=$((batch_end - batch_start))

  echo "=== Batch $batch_no — jobs $((batch_start+1))~$batch_end ($batch_size items) ==="
  bs=$(date +%s)

  declare -a PIDS=()
  for ((i=batch_start; i<batch_end; i++)); do
    run_one "$((i+1))" "${PROMPTS[$i]}" "${OUTPUTS[$i]}" &
    PIDS+=($!)
  done

  fail=0
  for pid in "${PIDS[@]}"; do
    if ! wait "$pid"; then
      fail=$((fail+1))
    fi
  done

  be=$(date +%s)
  echo "    batch elapsed: $((be - bs))s  (failed: $fail)"
  echo

  batch_start=$batch_end
  batch_no=$((batch_no+1))
done

overall_end=$(date +%s)
echo "[done] total elapsed: $((overall_end - overall_start))s"
echo "[done] outputs in:    $WORK_DIR"
echo "[done] codex logs in: $LOG_DIR"
