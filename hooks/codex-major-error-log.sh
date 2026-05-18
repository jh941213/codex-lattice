#!/usr/bin/env bash
set -uo pipefail

INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - <<'PY'
import datetime
import json
import os
import re
import subprocess
from pathlib import Path

def load_input():
    raw = os.environ.get("CODEX_HOOK_INPUT", "")
    try:
        return json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError:
        return {"raw": raw[:4000]}

def short(value, limit=1200):
    if value is None:
        return ""
    return str(value).strip().replace("\r", "")[:limit]

def resolve_cwd(data):
    tool_input = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else {}
    cwd = Path(data.get("cwd") or tool_input.get("workdir") or os.getcwd()).expanduser().resolve()
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

data = load_input()
tool_input = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else {}
cwd = resolve_cwd(data)

exit_code = data.get("exit_code") or data.get("returncode")
status = str(data.get("status") or "").lower()
error = short(data.get("error") or data.get("tool_error") or data.get("stderr") or data.get("output"))
text = f"{status}\n{exit_code}\n{error}"
is_failure = bool(exit_code not in (None, 0, "0")) or "fail" in status or "error" in status
is_major = is_failure and re.search(r"(traceback|exception|fatal|panic|permission denied|not found|failed|error)", text, re.I)
if not is_major:
    raise SystemExit(0)

event = data.get("hook_event_name") or data.get("event") or "PostToolUse"
tool = data.get("tool_name") or data.get("tool") or tool_input.get("tool") or "unknown"
cmd = short(tool_input.get("cmd") or tool_input.get("command") or data.get("command"), 500)
ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

visible_dir = cwd / ".codex-lattice" / "model-visible"
visible_dir.mkdir(parents=True, exist_ok=True)
path = visible_dir / "MAJOR_ERRORS.md"
if not path.exists():
    path.write_text("# Major Errors\n\n## Entries\n\n", encoding="utf-8")

entry = f"""\
### {ts}
- event: {event}
- tool: {tool}
- command: `{cmd or "(none)"}`
- failure: {error or status or exit_code}
- next action: Read this entry before retrying; change approach if the same tool/command failed repeatedly.

"""
with path.open("a", encoding="utf-8") as f:
    f.write(entry)
PY

exit 0
