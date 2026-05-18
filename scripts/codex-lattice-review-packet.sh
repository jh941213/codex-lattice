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

RISK_RULES = {
    "security": ("auth", "permission", "role", "secret", "token", "credential", ".env"),
    "api": ("api", "route", "controller", "endpoint", "openapi", "schema"),
    "infra": ("infra", "terraform", "bicep", "azure", "docker", "compose", "k8s", "helm", "systemd", "launchd", "cron"),
    "ui_ux": (".tsx", ".jsx", ".css", ".scss", ".vue", ".svelte", "component", "page", "screen"),
    "data": ("db", "database", "schema", "model", "entity", "migration", "sql", "prisma", "drizzle"),
    "supply_chain": ("package.json", "package-lock.json", "pnpm-lock", "yarn.lock", "requirements.txt", "pyproject.toml", "uv.lock", "go.mod", "cargo.toml"),
    "agent_tool": ("agent", "mcp", "hook", "plugin", "prompt", "subagent", "sub-agent", ".codex"),
    "scheduler_ops": ("scheduler", "schedule", "cron", "launchd", "systemd", "timer"),
}

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


def changed_files(cwd: Path) -> list[str]:
    names = set()
    for args in (["git", "diff", "--name-only"], ["git", "diff", "--cached", "--name-only"]):
        names.update(line for line in run(cwd, args).splitlines() if line)
    names.update(line for line in untracked_files(cwd))
    return sorted(names)


def untracked_files(cwd: Path) -> list[str]:
    return sorted(
        line
        for line in run(cwd, ["git", "ls-files", "--others", "--exclude-standard"]).splitlines()
        if line and not any(part in BIG_SKIP_DIRS for part in line.split("/"))
    )


def numstat(cwd: Path) -> tuple[int, int]:
    added = 0
    deleted = 0
    for args in (["git", "diff", "--numstat"], ["git", "diff", "--cached", "--numstat"]):
        for line in run(cwd, args).splitlines():
            parts = line.split("\t")
            if len(parts) < 3:
                continue
            try:
                added += int(parts[0])
                deleted += int(parts[1])
            except ValueError:
                continue
    return added, deleted


def detect_risks(files: list[str]) -> dict[str, list[str]]:
    found = {}
    for name, tokens in RISK_RULES.items():
        matches = []
        for path in files:
            low = path.lower()
            if any(token in low for token in tokens):
                matches.append(path)
        if matches:
            found[name] = matches[:20]
    return found


def read_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return {}


def latest_validation(cwd: Path) -> str:
    candidates = [
        cwd / ".codex-lattice" / "reports" / "health-latest.json",
        cwd / ".codex-lattice" / "reports" / "log-analysis-latest.json",
    ]
    lines = []
    for path in candidates:
        data = read_json(path)
        if not data:
            continue
        if path.name.startswith("health"):
            checks = data.get("checks") if isinstance(data.get("checks"), list) else []
            result = ", ".join(f"{c.get('name')}={c.get('status')}" for c in checks[:10] if isinstance(c, dict))
            lines.append(f"- `{path}`: {result or 'available'}")
        else:
            lines.append(
                f"- `{path}`: events={data.get('total_events', 0)}, failures={data.get('failure_count', 0)}"
            )
    return "\n".join(lines) if lines else "- no generated health/log reports found"


def gate_status(cwd: Path) -> str:
    visible = cwd / ".codex-lattice" / "model-visible"
    names = [
        "MAJOR_ERRORS.md",
        "REFLECTION_REQUIRED.md",
        "DOCS_AGENT_REQUIRED.md",
        "SIMPLIFY_REQUIRED.md",
        "CONTEXT_PACKET.md",
        "HARNESS_HEALTH.md",
    ]
    rows = []
    for name in names:
        path = visible / name
        rows.append(f"- `{name}`: {'present' if path.exists() else 'absent'}")
    return "\n".join(rows)


def bullet(items: list[str], empty: str = "- none") -> str:
    if not items:
        return empty
    return "\n".join(f"- `{item}`" for item in items[:80])


def risk_text(risks: dict[str, list[str]]) -> str:
    if not risks:
        return "- no file-path risk categories detected"
    lines = []
    for name, files in sorted(risks.items()):
        lines.append(f"- {name}: " + ", ".join(f"`{path}`" for path in files[:12]))
    return "\n".join(lines)


def write_packet(cwd: Path, data: dict) -> Path:
    now = datetime.datetime.now(datetime.timezone.utc)
    ts = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    session_id = str(data.get("session_id") or data.get("conversation_id") or "").strip()[:120]
    branch = run(cwd, ["git", "branch", "--show-current"]) or "detached-or-non-git"
    files = changed_files(cwd)
    untracked = untracked_files(cwd)
    added, deleted = numstat(cwd)
    stat = run(cwd, ["git", "diff", "--stat"]) or "(no unstaged diff stat)"
    staged_stat = run(cwd, ["git", "diff", "--cached", "--stat"]) or "(no staged diff stat)"
    risks = detect_risks(files)
    risk_level = "high" if {"security", "infra", "agent_tool"} & set(risks) else "medium" if risks else "low"
    prompt = str(data.get("prompt") or data.get("user_prompt") or "").strip().replace("\n", " ")[:500]

    content = f"""# Review Packet

Generated: {ts}

## Review Boundary
- session: `{session_id or "unknown"}`
- branch: `{branch}`
- risk level: `{risk_level}`
- prompt summary: {prompt or "(not available from hook input)"}

## Change Size
- files changed: {len(files)}
- added lines: {added}
- deleted lines: {deleted}

## Changed Files
{bullet(files)}

## Untracked Files
{bullet(untracked)}

## Risk Routing
{risk_text(risks)}

## Diff Stat

```text
{stat}
```

## Staged Diff Stat

```text
{staged_stat}
```

## Gate Status
{gate_status(cwd)}

## Validation Evidence
{latest_validation(cwd)}

## Review Checklist
- Confirm scope matches the newest user request.
- Review high-risk categories before style or cleanup.
- Check that docs gates are reconciled with the actual diff.
- Check that simplify gate was considered for code changes.
- Treat hidden logs as evidence, not as source of truth.
- Re-run targeted validation after any patch.
"""
    visible = cwd / ".codex-lattice" / "model-visible"
    visible.mkdir(parents=True, exist_ok=True)
    out = visible / "REVIEW_PACKET.md"
    out.write_text(content.rstrip() + "\n", encoding="utf-8")

    run_id = session_id or now.strftime("%Y%m%dT%H%M%SZ") + "-" + hashlib.sha1(str(cwd).encode()).hexdigest()[:8]
    run_dir = cwd / ".codex-lattice" / "runs" / run_id
    run_dir.mkdir(parents=True, exist_ok=True)
    (run_dir / "review-packet.md").write_text(content.rstrip() + "\n", encoding="utf-8")
    return out


data = load_input()
cwd = resolve_cwd(data)
path = write_packet(cwd, data)
print(path)
PY
