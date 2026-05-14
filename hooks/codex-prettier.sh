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

tool_input = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else {}
path = tool_input.get("path") or tool_input.get("file_path") or data.get("file_path")
if not path:
    raise SystemExit(0)

target = Path(path).expanduser()
if target.suffix not in {".ts", ".tsx", ".js", ".jsx", ".json", ".css", ".md"}:
    raise SystemExit(0)
if not target.exists():
    raise SystemExit(0)

try:
    subprocess.run(["prettier", "--write", str(target)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
except FileNotFoundError:
    pass
PY

exit 0
