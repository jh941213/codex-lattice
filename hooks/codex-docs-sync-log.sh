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
tool_input = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else {}
cwd = Path(data.get("cwd") or tool_input.get("workdir") or os.getcwd()).expanduser().resolve()
root = run(cwd, ["git", "rev-parse", "--show-toplevel"])
if root:
    cwd = Path(root)

changed = sorted(set(filter(None, run(cwd, ["git", "diff", "--name-only"]).splitlines())))
if not changed:
    raise SystemExit(0)

docs = cwd / "docs" / "harness"
docs.mkdir(parents=True, exist_ok=True)
for name, content in {
    "README.md": "# Harness Docs\n\nModel-visible docs for Codex coding work.\n",
    "TASKS.md": "# Tasks\n\n- [ ] Keep this file aligned with current implementation work.\n",
    "DECISIONS.md": "# Decisions\n\n",
    "CHANGELOG.md": "# Harness Changelog\n\n## Unreleased\n\n",
    "VALIDATION.md": "# Validation\n\n",
    "RISKS.md": "# Risks\n\n",
}.items():
    p = docs / name
    if not p.exists():
        p.write_text(content, encoding="utf-8")

entry = {
    "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "changed_files": changed,
    "docs_dir": "docs/harness",
    "instruction": "Reconcile docs/harness before final response; use docs_maintainer only when agent delegation is explicitly allowed.",
}
harness = cwd / ".codex-lattice"
harness.mkdir(parents=True, exist_ok=True)
with (harness / "docs-sync-queue.jsonl").open("a", encoding="utf-8") as f:
    f.write(json.dumps(entry, ensure_ascii=False, sort_keys=True) + "\n")
PY

exit 0
