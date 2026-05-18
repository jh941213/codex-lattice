#!/usr/bin/env bash
set -uo pipefail

INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - <<'PY'
import json
import os
import subprocess
from pathlib import Path

raw = os.environ.get("CODEX_HOOK_INPUT", "")
try:
    data = json.loads(raw) if raw.strip() else {}
except json.JSONDecodeError:
    data = {}

cwd = Path(data.get("cwd") or data.get("working_dir") or os.getcwd()).expanduser().resolve()
try:
    root = subprocess.check_output(
        ["git", "rev-parse", "--show-toplevel"],
        cwd=str(cwd),
        stderr=subprocess.DEVNULL,
        text=True,
    ).strip()
except Exception:
    root = ""
if root:
    cwd = Path(root)
path = cwd / ".codex-lattice" / "model-visible" / "MAJOR_ERRORS.md"
if not path.exists():
    raise SystemExit(0)

text = path.read_text(encoding="utf-8", errors="ignore")
entries = text.count("### ")
if entries > 0:
    print(f"Model-visible major error log has {entries} entries: {path}")
PY

exit 0
