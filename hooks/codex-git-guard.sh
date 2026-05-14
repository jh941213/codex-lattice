#!/usr/bin/env bash
set -uo pipefail

INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - <<'PY'
import json
import os
import re
import subprocess
import sys
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
if not cmd:
    raise SystemExit(0)

cwd = Path(data.get("cwd") or tool_input.get("workdir") or os.getcwd()).expanduser().resolve()
root = run(cwd, ["git", "rev-parse", "--show-toplevel"])
if root:
    cwd = Path(root)

branch = run(cwd, ["git", "branch", "--show-current"])
is_protected = branch in {"main", "master", "production", "prod"}

if re.search(r"\bgit\s+push\b", cmd) and (("--force" in cmd) or (" -f" in cmd)):
    print("BLOCKED: force push is not allowed by my-codex-harness.", file=sys.stderr)
    raise SystemExit(2)

if is_protected and re.search(r"\bgit\s+(commit|push)\b", cmd):
    print(f"BLOCKED: direct git commit/push on protected branch '{branch}' is not allowed.", file=sys.stderr)
    raise SystemExit(2)

if re.search(r"\bgit\s+commit\b", cmd):
    staged = run(cwd, ["git", "diff", "--cached", "--name-only"])
    staged_names = [name for name in staged.splitlines() if name]
    if any(name.endswith(".env") or "/.env" in name for name in staged_names):
        print("BLOCKED: .env files must not be committed.", file=sys.stderr)
        raise SystemExit(2)

    code_suffixes = {".js", ".jsx", ".ts", ".tsx", ".mjs", ".cjs", ".vue", ".svelte"}
    code_files = [
        name for name in staged_names
        if Path(name).suffix.lower() in code_suffixes
    ]
    diff = run(cwd, ["git", "diff", "--cached", "--", *code_files]) if code_files else ""
    if diff and re.search(r"console\.(log|warn|debug)\(", diff, flags=re.IGNORECASE):
        print("BLOCKED: staged diff contains console.log/warn/debug.", file=sys.stderr)
        raise SystemExit(2)
PY

exit $?
