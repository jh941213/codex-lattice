#!/usr/bin/env bash
set -uo pipefail

EVENT="${1:-}"
INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_EVENT="$EVENT" CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - <<'PY'
import datetime
import json
import os
import subprocess
from pathlib import Path

def load_input():
    raw = os.environ.get("CODEX_HOOK_INPUT", "")
    try:
        return json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError:
        return {"raw": raw[:4000]}

def project_dir(data):
    candidates = [
        data.get("cwd"),
        data.get("working_dir"),
        data.get("project_dir"),
        data.get("tool_input", {}).get("workdir") if isinstance(data.get("tool_input"), dict) else None,
        os.getcwd(),
    ]
    for value in candidates:
        if value:
            cwd = Path(value).expanduser().resolve()
            break
    else:
        cwd = Path.cwd()
    try:
        root = subprocess.check_output(
            ["git", "rev-parse", "--show-toplevel"],
            cwd=str(cwd),
            stderr=subprocess.DEVNULL,
            text=True,
        ).strip()
    except Exception:
        root = ""
    return Path(root) if root else cwd

def short(value, limit=500):
    if value is None:
        return None
    text = str(value).replace("\n", "\\n")
    return text[:limit]

data = load_input()
cwd = project_dir(data)
event = os.environ.get("CODEX_HOOK_EVENT") or data.get("hook_event_name") or data.get("event") or "unknown"
tool_input = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else {}
tool_name = data.get("tool_name") or data.get("tool") or tool_input.get("tool")
cmd = tool_input.get("cmd") or tool_input.get("command") or data.get("command")

entry = {
    "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "event": event,
    "session_id": data.get("session_id"),
    "cwd": str(cwd),
    "tool_name": tool_name,
    "command": short(cmd),
    "status": data.get("status"),
    "exit_code": data.get("exit_code") or data.get("returncode"),
    "error": short(data.get("error") or data.get("tool_error") or data.get("stderr")),
}

log_dir = cwd / ".codex-lattice" / "logs"
log_dir.mkdir(parents=True, exist_ok=True)
with (log_dir / "events.jsonl").open("a", encoding="utf-8") as f:
    f.write(json.dumps(entry, ensure_ascii=False, sort_keys=True) + "\n")
PY

exit 0
