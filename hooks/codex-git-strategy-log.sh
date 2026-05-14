#!/usr/bin/env bash
set -uo pipefail

INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - <<'PY'
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
        return {}

def run(cwd, args):
    try:
        return subprocess.check_output(args, cwd=str(cwd), stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        return ""

data = load_input()
cwd = Path(data.get("cwd") or data.get("working_dir") or os.getcwd()).expanduser().resolve()
if not (cwd / ".git").exists() and not run(cwd, ["git", "rev-parse", "--is-inside-work-tree"]):
    raise SystemExit(0)

root = run(cwd, ["git", "rev-parse", "--show-toplevel"])
if root:
    cwd = Path(root)

branch = run(cwd, ["git", "branch", "--show-current"]) or "detached"
status = run(cwd, ["git", "status", "--short"])
prompt = data.get("prompt") or data.get("user_prompt") or ""
prompt = " ".join(str(prompt).split())[:240]
ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

harness = cwd / ".codex-harness"
harness.mkdir(parents=True, exist_ok=True)
path = harness / "git-strategy.md"
if not path.exists():
    path.write_text("# Git Strategy Log\n\n", encoding="utf-8")

entry = f"""\
### {ts}
- branch: {branch}
- scope: {prompt or "new Codex task"}
- commit split: decide before editing; keep unrelated changes separate
- validation: choose commands before final response
- rollback: keep changes reviewable with git diff; avoid destructive resets
- dirty status before task:
```text
{status or "clean"}
```

"""
with path.open("a", encoding="utf-8") as f:
    f.write(entry)
PY

exit 0
