#!/usr/bin/env bash
set -euo pipefail

INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - "$@" <<'PY'
import datetime
import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

TEXT_LIMIT = 900
FILE_LIMIT = 60

SENSITIVE_PARTS = (
    ".env",
    "secret",
    "token",
    "credential",
    "private_key",
    "id_rsa",
    ".pem",
    ".key",
)

BIG_SKIP_DIRS = {
    ".git",
    ".codex-lattice",
    "node_modules",
    "dist",
    "build",
    "coverage",
    ".next",
    "vendor",
}


def load_input() -> dict:
    raw = os.environ.get("CODEX_HOOK_INPUT", "")
    try:
        return json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError:
        return {"raw": raw[:4000]}


def run(cwd: Path, args: list[str]) -> str:
    try:
        return subprocess.check_output(args, cwd=str(cwd), stderr=subprocess.DEVNULL, text=True).strip()
    except Exception:
        return ""


def resolve_cwd(data: dict) -> Path:
    tool_input = data.get("tool_input") if isinstance(data.get("tool_input"), dict) else {}
    candidates = [
        sys.argv[1] if len(sys.argv) > 1 else None,
        data.get("cwd"),
        data.get("working_dir"),
        data.get("project_dir"),
        tool_input.get("workdir"),
        os.getcwd(),
    ]
    cwd = next((Path(v).expanduser().resolve() for v in candidates if v), Path.cwd())
    root = run(cwd, ["git", "rev-parse", "--show-toplevel"])
    return Path(root) if root else cwd


def short(text: object, limit: int = TEXT_LIMIT) -> str:
    if text is None:
        return ""
    value = str(text).replace("\r", "").strip()
    return value[:limit]


def is_sensitive(path: str) -> bool:
    low = path.lower()
    return any(part in low for part in SENSITIVE_PARTS)


def changed_files(cwd: Path) -> list[str]:
    names = set()
    for args in (["git", "diff", "--name-only"], ["git", "diff", "--cached", "--name-only"]):
        names.update(line for line in run(cwd, args).splitlines() if line)
    names.update(
        line
        for line in run(cwd, ["git", "ls-files", "--others", "--exclude-standard"]).splitlines()
        if line and not any(part in BIG_SKIP_DIRS for part in line.split("/"))
    )
    return sorted(names)


def recent_files(cwd: Path) -> list[str]:
    try:
        files = []
        for path in cwd.rglob("*"):
            rel = path.relative_to(cwd).as_posix()
            if any(part in BIG_SKIP_DIRS for part in rel.split("/")):
                continue
            if path.is_file() and not is_sensitive(rel):
                files.append(rel)
            if len(files) >= FILE_LIMIT:
                break
        return sorted(files)
    except Exception:
        return []


def package_scripts(cwd: Path) -> dict:
    path = cwd / "package.json"
    if not path.exists():
        return {}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}
    scripts = data.get("scripts")
    return scripts if isinstance(scripts, dict) else {}


def required_docs(cwd: Path) -> list[str]:
    queue = cwd / ".codex-lattice" / "docs-sync-queue.jsonl"
    if not queue.exists():
        return []
    last = ""
    for line in queue.read_text(encoding="utf-8", errors="ignore").splitlines():
        if line.strip():
            last = line
    if not last:
        return []
    try:
        data = json.loads(last)
    except Exception:
        return []
    docs = data.get("required_docs")
    return docs if isinstance(docs, list) else []


def validation_commands(cwd: Path) -> list[str]:
    scripts = package_scripts(cwd)
    commands = []
    for key in ("typecheck", "lint", "test", "build"):
        if key in scripts:
            commands.append(f"npm run {key}")
    if (cwd / "pyproject.toml").exists():
        commands.extend(["ruff check .", "pytest -q"])
    if (cwd / "go.mod").exists():
        commands.extend(["go test ./...", "go vet ./..."])
    if (cwd / "Cargo.toml").exists():
        commands.extend(["cargo test", "cargo clippy --all-targets --all-features"])
    commands.append("gitleaks detect --source . --no-git --redact --no-banner")
    return commands


def bullet(items: list[str], empty: str = "- none") -> str:
    visible = [item for item in items if item]
    if not visible:
        return empty
    return "\n".join(f"- `{item}`" for item in visible[:FILE_LIMIT])


def write_packet(cwd: Path, data: dict) -> Path:
    now = datetime.datetime.now(datetime.timezone.utc)
    ts = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    session_id = short(data.get("session_id") or data.get("conversation_id") or "", 120)
    prompt = short(data.get("prompt") or data.get("user_prompt") or data.get("raw") or "", 500)
    branch = run(cwd, ["git", "branch", "--show-current"]) or "detached-or-non-git"
    status = run(cwd, ["git", "status", "--short"]) or "clean"
    commits = run(cwd, ["git", "log", "--oneline", "-5"]) or "(none)"
    changed = changed_files(cwd)
    docs = required_docs(cwd)
    scripts = package_scripts(cwd)
    candidates = [
        "AGENTS.md",
        "README.md",
        "docs/harness/README.md",
        ".codex-lattice/model-visible/MAJOR_ERRORS.md",
        ".codex-lattice/model-visible/REFLECTION_REQUIRED.md",
        ".codex-lattice/model-visible/DOCS_AGENT_REQUIRED.md",
        ".codex-lattice/model-visible/SIMPLIFY_REQUIRED.md",
    ]
    candidates.extend(f"docs/harness/{name}" for name in docs)
    candidates.extend(changed)
    existing_candidates = []
    for item in candidates:
        if item and (cwd / item).exists() and item not in existing_candidates and not is_sensitive(item):
            existing_candidates.append(item)

    recent = [name for name in recent_files(cwd) if name not in existing_candidates]
    commands = validation_commands(cwd)

    content = f"""# Context Packet

Generated: {ts}

## Task Boundary
- session: `{session_id or "unknown"}`
- prompt summary: {prompt or "(not available from hook input)"}
- branch: `{branch}`

## Current Git State

```text
{status}
```

## Recent Commits

```text
{commits}
```

## Changed Files
{bullet(changed)}

## Required Reading
Read these first. They are small, local, and directly relevant to the current run.

{bullet(existing_candidates)}

## Nearby Files
Use `rg`, `sg`, or `mgrep` before opening broad files.

{bullet(recent[:30])}

## Package Scripts

```json
{json.dumps(scripts, ensure_ascii=False, indent=2, sort_keys=True)}
```

## Validation Candidates
{bullet(commands, "- no validation candidates detected")}

## Retrieval Rules
- Prefer `rg` for exact text and file discovery.
- Prefer `sg` for AST patterns.
- Prefer `mgrep` for semantic local search only when policy allows indexed local content.
- Use Tavily for fresh web/page extraction and Exa for evidence-oriented research.
- Do not read secrets, `.env` files, credentials, large generated folders, or hidden runtime logs unless explicitly needed.
- Treat this packet as a routing aid, not as source of truth. Verify against files and command output.
"""

    visible = cwd / ".codex-lattice" / "model-visible"
    visible.mkdir(parents=True, exist_ok=True)
    out = visible / "CONTEXT_PACKET.md"
    out.write_text(content.rstrip() + "\n", encoding="utf-8")

    run_id = session_id or now.strftime("%Y%m%dT%H%M%SZ") + "-" + hashlib.sha1(str(cwd).encode()).hexdigest()[:8]
    run_dir = cwd / ".codex-lattice" / "runs" / run_id
    run_dir.mkdir(parents=True, exist_ok=True)
    (run_dir / "context-packet.md").write_text(content.rstrip() + "\n", encoding="utf-8")
    return out


data = load_input()
cwd = resolve_cwd(data)
path = write_packet(cwd, data)
print(path)
PY
