#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${1:-$ROOT/.codex-lattice/reports}"
LOG_FILE="${2:-$ROOT/.codex-lattice/logs/events.jsonl}"
mkdir -p "$OUT_DIR"

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
JSON_OUT="$OUT_DIR/log-analysis-latest.json"
MD_OUT="$OUT_DIR/log-analysis-latest.md"

python3 - "$LOG_FILE" "$JSON_OUT" "$TS" <<'PY'
import collections
import json
import sys
from pathlib import Path

log_path = Path(sys.argv[1])
out_path = Path(sys.argv[2])
ts = sys.argv[3]

events = []
if log_path.exists():
    for line in log_path.read_text(encoding="utf-8", errors="ignore").splitlines():
        try:
            events.append(json.loads(line))
        except Exception:
            continue

by_event = collections.Counter(str(e.get("event") or "unknown") for e in events)
by_tool = collections.Counter(str(e.get("tool_name") or "unknown") for e in events)
failures = [
    e for e in events
    if str(e.get("status") or "").lower() in {"fail", "failed", "error"}
    or str(e.get("exit_code") or "0") not in {"0", "None", ""}
]
failure_tools = collections.Counter(str(e.get("tool_name") or "unknown") for e in failures)
recent_failures = failures[-10:]

summary = {
    "ts": ts,
    "log_file": str(log_path),
    "exists": log_path.exists(),
    "total_events": len(events),
    "events_by_type": dict(by_event.most_common()),
    "top_tools": dict(by_tool.most_common(10)),
    "failure_count": len(failures),
    "failure_tools": dict(failure_tools.most_common(10)),
    "recent_failures": recent_failures,
}
out_path.write_text(json.dumps(summary, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
PY

{
	printf "# Codex Lattice Log Analysis\n\n"
	printf -- "- generated: %s\n" "$TS"
	printf -- "- log file: %s\n\n" "$LOG_FILE"
	jq -r '"- log exists: \(.exists)\n- total events: \(.total_events)\n- failures: \(.failure_count)\n"' "$JSON_OUT"
	printf "## Events By Type\n\n"
	jq -r '.events_by_type | to_entries[]? | "- \(.key): \(.value)"' "$JSON_OUT"
	printf "\n## Failure Tools\n\n"
	jq -r '.failure_tools | to_entries[]? | "- \(.key): \(.value)"' "$JSON_OUT"
} >"$MD_OUT"

printf "%s\n" "$MD_OUT"
