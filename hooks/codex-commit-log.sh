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
        return {}

def run(cwd, args):
    try:
        return subprocess.check_output(args, cwd=str(cwd), stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        return ""

data = load_input()
tool_input = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else {}
cmd = str(tool_input.get("cmd") or tool_input.get("command") or data.get("command") or "")
if not re.search(r"\bgit\s+commit\b", cmd):
    raise SystemExit(0)

cwd = Path(data.get("cwd") or tool_input.get("workdir") or os.getcwd()).expanduser().resolve()
root = run(cwd, ["git", "rev-parse", "--show-toplevel"])
if root:
    cwd = Path(root)

commit = run(cwd, ["git", "rev-parse", "HEAD"])
if not commit:
    raise SystemExit(0)

subject = run(cwd, ["git", "log", "-1", "--format=%s"])
body = run(cwd, ["git", "log", "-1", "--format=%b"])
author = run(cwd, ["git", "log", "-1", "--format=%an <%ae>"])
changed = run(cwd, ["git", "diff-tree", "--no-commit-id", "--name-only", "-r", "HEAD"]).splitlines()
stat = run(cwd, ["git", "diff", "--stat", "HEAD~1", "HEAD"])
ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")

out_dir = cwd / ".codex-lattice" / "commits"
out_dir.mkdir(parents=True, exist_ok=True)
payload = {
    "timestamp": ts,
    "commit": commit,
    "subject": subject,
    "body": body,
    "author": author,
    "changed_files": changed,
    "stat": stat,
    "command": cmd,
}
(out_dir / f"{ts}-{commit[:12]}.json").write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
(out_dir / f"{ts}-{commit[:12]}.md").write_text(
    f"# Commit Log: {commit[:12]}\n\n"
    f"- timestamp: {ts}\n"
    f"- author: {author}\n"
    f"- subject: {subject}\n\n"
    f"## Body\n\n{body or '(none)'}\n\n"
    f"## Changed Files\n\n" + "\n".join(f"- {name}" for name in changed) + "\n\n"
    f"## Stat\n\n```text\n{stat}\n```\n",
    encoding="utf-8",
)
PY

exit 0
