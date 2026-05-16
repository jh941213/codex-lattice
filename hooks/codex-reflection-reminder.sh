#!/usr/bin/env bash
set -uo pipefail

EVENT="${1:-}"
INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_EVENT="$EVENT" CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - <<'PY'
import datetime
import json
import os
import re
import subprocess
from pathlib import Path

SEQUENCE_MARKERS = (
    "먼저", "다음", "그다음", "그리고", "또", "추가로", "마지막", "이후", "전에", "후에",
    "순차", "여러개", "여러 개", "워크플로우", "계속", "반영해", "처리하고",
    "first", "then", "next", "after", "before", "finally", "also", "workflow", "sequence",
)

ACTION_MARKERS = (
    "수정", "추가", "삭제", "검증", "테스트", "설치", "커밋", "푸시", "푸쉬", "pr", "merge",
    "반영", "정리", "업데이트", "문서", "리드미", "훅", "룰", "agent", "skill",
    "fix", "add", "remove", "verify", "test", "install", "commit", "push", "update", "docs",
)


def load_input():
    raw = os.environ.get("CODEX_HOOK_INPUT", "")
    try:
        return json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError:
        return {"raw": raw}


def run(cwd, args):
    try:
        return subprocess.check_output(args, cwd=str(cwd), stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        return ""


def resolve_cwd(data):
    tool_input = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else {}
    cwd_value = (
        data.get("cwd")
        or data.get("working_dir")
        or tool_input.get("workdir")
        or tool_input.get("cwd")
        or os.getcwd()
    )
    cwd = Path(cwd_value).expanduser().resolve()
    root = run(cwd, ["git", "rev-parse", "--show-toplevel"])
    return Path(root) if root else cwd


def collect_prompt_text(value):
    candidates = []
    priority_keys = ("prompt", "user_prompt", "message", "input", "text", "content", "raw")

    def walk(item, depth=0):
        if depth > 4:
            return
        if isinstance(item, str):
            if item.strip():
                candidates.append(item)
            return
        if isinstance(item, dict):
            for key in priority_keys:
                child = item.get(key)
                if isinstance(child, (str, dict, list)):
                    walk(child, depth + 1)
            for child in item.values():
                if isinstance(child, (dict, list)):
                    walk(child, depth + 1)
            return
        if isinstance(item, list):
            for child in item[:20]:
                walk(child, depth + 1)

    walk(value)
    seen = set()
    merged = []
    for item in candidates:
        text = item.strip()
        if text and text not in seen:
            seen.add(text)
            merged.append(text)
    return "\n".join(merged)


def marker_hits(text, markers):
    low = text.lower()
    return [marker for marker in markers if marker.lower() in low]


def bullet_count(text):
    count = 0
    for line in text.splitlines():
        if re.match(r"^\s*(?:[-*+]|\d+[.)])\s+", line):
            count += 1
    return count


def reflection_reasons(event, prompt):
    if event == "PostCompact":
        return ["context compaction occurred; re-check the newest instruction before continuing"]

    if event != "UserPromptSubmit" or not prompt.strip():
        return []

    sequence = marker_hits(prompt, SEQUENCE_MARKERS)
    actions = marker_hits(prompt, ACTION_MARKERS)
    bullets = bullet_count(prompt)
    lines = len([line for line in prompt.splitlines() if line.strip()])
    score = 0
    reasons = []

    if len(sequence) >= 2:
        score += 2
        reasons.append("multiple sequence markers: " + ", ".join(sequence[:8]))
    elif len(sequence) == 1:
        score += 1
        reasons.append("sequence marker: " + sequence[0])

    if len(actions) >= 3:
        score += 2
        reasons.append("multiple action markers: " + ", ".join(actions[:10]))
    elif len(actions) >= 1:
        score += 1
        reasons.append("action marker: " + ", ".join(actions[:3]))

    if bullets >= 2:
        score += 2
        reasons.append(f"structured list items: {bullets}")

    if lines >= 4:
        score += 1
        reasons.append(f"multi-line prompt: {lines} lines")

    if len(prompt) >= 500:
        score += 1
        reasons.append(f"long prompt: {len(prompt)} characters")

    if score >= 3:
        return reasons
    return []


def excerpt(text, limit=1200):
    cleaned = re.sub(r"\s+", " ", text).strip()
    if len(cleaned) <= limit:
        return cleaned
    return cleaned[: limit - 3] + "..."


data = load_input()
event = os.environ.get("CODEX_HOOK_EVENT") or data.get("hook_event_name") or data.get("event") or "unknown"
cwd = resolve_cwd(data if isinstance(data, dict) else {})
harness = cwd / ".codex-lattice"
visible = harness / "model-visible"
required_path = visible / "REFLECTION_REQUIRED.md"

if event == "Stop":
    if required_path.exists():
        print(f"Reflection gate pending before final response: {required_path}")
    raise SystemExit(0)

prompt = collect_prompt_text(data)
reasons = reflection_reasons(event, prompt)
if not reasons:
    raise SystemExit(0)

visible.mkdir(parents=True, exist_ok=True)
ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
reason_lines = "\n".join(f"- {reason}" for reason in reasons)
prompt_block = excerpt(prompt) or "(prompt text unavailable)"

required_path.write_text(f"""# Reflection Required

Last updated: {ts}

## Why This Gate Triggered
{reason_lines}

## Required Before Acting Or Continuing
- Read `docs/harness/REFLECTION.md`.
- Rebuild an instruction ledger from the newest user message, not from stale session momentum.
- Identify ordered steps, dependencies, non-negotiables, current step, and completion criteria.
- After each major step, check whether the next action still matches the newest user request.
- Before final response, run the newest-request check and mention any skipped or blocked work.

## Latest User Request Excerpt
{prompt_block}

## Notes
- This hook is advisory and never edits code automatically.
- If the request is ambiguous, ask only for the missing decision that cannot be safely inferred.
""", encoding="utf-8")

print(f"Reflection gate required for multi-step or resumed work: {required_path}")
PY

exit 0
