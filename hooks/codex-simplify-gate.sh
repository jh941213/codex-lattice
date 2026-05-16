#!/usr/bin/env bash
set -uo pipefail

EVENT="${1:-}"
INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_EVENT="$EVENT" CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - <<'PY'
import datetime
import hashlib
import json
import os
import subprocess
from pathlib import Path

CODE_EXTENSIONS = {
    ".ts", ".tsx", ".js", ".jsx", ".mjs", ".cjs",
    ".py", ".go", ".rs", ".java", ".kt", ".kts", ".swift",
    ".rb", ".php", ".cs", ".cpp", ".cc", ".c", ".h", ".hpp",
    ".sh", ".bash", ".zsh", ".fish",
    ".css", ".scss", ".sass", ".less",
    ".vue", ".svelte",
}

EXCLUDED_PREFIXES = (
    ".git/",
    ".codex-lattice/",
    "docs/harness/",
    "node_modules/",
    "vendor/",
    "dist/",
    "build/",
    "coverage/",
)

def load_input():
    raw = os.environ.get("CODEX_HOOK_INPUT", "")
    try:
        return json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError:
        return {}

def run(cwd, args):
    try:
        return subprocess.check_output(args, cwd=str(cwd), stderr=subprocess.DEVNULL, text=True)
    except Exception:
        return ""

def resolve_cwd(data):
    tool_input = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else {}
    cwd = Path(data.get("cwd") or tool_input.get("workdir") or os.getcwd()).expanduser().resolve()
    root = run(cwd, ["git", "rev-parse", "--show-toplevel"]).strip()
    return Path(root) if root else cwd

def is_code_file(path):
    if any(path.startswith(prefix) for prefix in EXCLUDED_PREFIXES):
        return False
    suffix = Path(path).suffix.lower()
    return suffix in CODE_EXTENSIONS

def changed_files(cwd):
    names = set()
    for args in (["git", "diff", "--name-only"], ["git", "diff", "--cached", "--name-only"]):
        names.update(line.strip() for line in run(cwd, args).splitlines() if line.strip())
    return sorted(names)

def numstat(cwd):
    lines = []
    for args in (["git", "diff", "--numstat"], ["git", "diff", "--cached", "--numstat"]):
        lines.extend(run(cwd, args).splitlines())
    totals = {}
    for line in lines:
        parts = line.split("\t")
        if len(parts) < 3:
            continue
        add, delete, path = parts[0], parts[1], parts[2]
        if not is_code_file(path):
            continue
        try:
            changed = int(add) + int(delete)
        except ValueError:
            changed = 0
        totals[path] = totals.get(path, 0) + changed
    return totals

def read_state(path):
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {"dirty_rounds": 0, "file_counts": {}}

data = load_input()
event = os.environ.get("CODEX_HOOK_EVENT") or data.get("hook_event_name") or data.get("event") or "unknown"
cwd = resolve_cwd(data)
harness = cwd / ".codex-lattice"
visible_dir = harness / "model-visible"
visible_dir.mkdir(parents=True, exist_ok=True)
state_path = harness / "simplify-state.json"
required_path = visible_dir / "SIMPLIFY_REQUIRED.md"

files = changed_files(cwd)
code_files = [p for p in files if is_code_file(p)]
if not code_files:
    state_path.write_text(json.dumps({"dirty_rounds": 0, "file_counts": {}}, sort_keys=True), encoding="utf-8")
    if required_path.exists():
        required_path.unlink()
    raise SystemExit(0)

stats = numstat(cwd)
total_lines = sum(stats.values())
signature_source = "\n".join(code_files) + "\n" + "\n".join(f"{p}:{stats.get(p, 0)}" for p in code_files)
signature = hashlib.sha256(signature_source.encode("utf-8")).hexdigest()
state = read_state(state_path)

if state.get("last_signature") != signature:
    state["dirty_rounds"] = int(state.get("dirty_rounds") or 0) + 1
    counts = state.get("file_counts") if isinstance(state.get("file_counts"), dict) else {}
    for path in code_files:
        counts[path] = int(counts.get(path) or 0) + 1
    state["file_counts"] = counts
    state["last_signature"] = signature
    state["updated_at"] = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

state_path.parent.mkdir(parents=True, exist_ok=True)
state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")

dirty_rounds = int(state.get("dirty_rounds") or 0)
counts = state.get("file_counts") if isinstance(state.get("file_counts"), dict) else {}
repeated = sorted(path for path, count in counts.items() if int(count or 0) >= 3 and path in code_files)

is_hitl_gate = event in {"PermissionRequest", "Stop"}
reasons = []
if is_hitl_gate:
    reasons.append(f"{event} before human/final handoff with code diff")
if dirty_rounds >= 3:
    reasons.append(f"dirty code observations: {dirty_rounds}")
if len(code_files) >= 3:
    reasons.append(f"changed code files: {len(code_files)}")
if total_lines >= 150:
    reasons.append(f"changed code lines: {total_lines}")
if repeated:
    reasons.append("files observed in 3+ dirty revisions: " + ", ".join(repeated[:8]))

if not reasons:
    raise SystemExit(0)

ts = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
file_lines = "\n".join(f"- `{path}` ({stats.get(path, 0)} changed lines)" for path in code_files[:30])
reason_lines = "\n".join(f"- {reason}" for reason in reasons)

required_path.write_text(f"""# Simplify Required

Last updated: {ts}

## Why This Gate Triggered
{reason_lines}

## Required Before HITL, Review, Or Final Response
- Run the simplify checklist on changed code before asking for human review.
- Remove unnecessary abstraction, reduce nesting, normalize boundary shapes, and keep behavior unchanged.
- Do not merge unrelated domains just because code looks similar.
- Re-run verification after simplification.
- Update `docs/harness/VALIDATION.md` with the simplify and verification result.

## Changed Code Files
{file_lines}

## Notes
- This hook is advisory and never edits code automatically.
- If simplification is unsafe or blocked, document the reason in `docs/harness/RISKS.md` before HITL.
""", encoding="utf-8")

print(f"Simplify gate required before HITL/final response: {required_path}")
PY

exit 0
