#!/usr/bin/env bash
set -euo pipefail

INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - "$@" <<'PY'
import datetime
import json
import os
import subprocess
import sys
from pathlib import Path


def load_input() -> dict:
    raw = os.environ.get("CODEX_HOOK_INPUT", "")
    try:
        return json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError:
        return {}


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


def codex_config_summary() -> dict:
    config = Path.home() / ".codex" / "config.toml"
    summary = {"config_exists": config.exists()}
    if not config.exists():
        return summary
    text = config.read_text(encoding="utf-8")
    try:
        import tomllib

        data = tomllib.loads(text)
        features = data.get("features", {})
        hooks = data.get("hooks", {})
        summary.update(
            {
                "features": {
                    key: features.get(key)
                    for key in ["hooks", "multi_agent", "plugins", "goals", "image_generation", "codex_hooks"]
                },
                "skills_config": len(data.get("skills", {}).get("config", [])),
                "hook_commands": sum(
                    len(item.get("hooks", [])) for entries in hooks.values() for item in entries
                )
                if isinstance(hooks, dict)
                else 0,
            }
        )
    except Exception as exc:
        features = {}
        in_features = False
        for line in text.splitlines():
            stripped = line.strip()
            if stripped.startswith("[") and stripped.endswith("]"):
                in_features = stripped == "[features]"
                continue
            if in_features and "=" in stripped:
                key, value = [part.strip() for part in stripped.split("=", 1)]
                if value.lower() in {"true", "false"}:
                    features[key] = value.lower() == "true"
        summary.update(
            {
                "features": {
                    key: features.get(key)
                    for key in ["hooks", "multi_agent", "plugins", "goals", "image_generation", "codex_hooks"]
                },
                "skills_config": text.count("[[skills.config]]"),
                "hook_commands": text.count('type = "command"'),
                "parser_fallback": str(exc),
            }
        )
    home = Path.home() / ".codex"
    summary["skill_dirs"] = len([p for p in (home / "skills").glob("*") if p.is_dir() and p.name != ".system"])
    summary["agents"] = len(list((home / "agents").glob("*.toml")))
    summary["hook_scripts"] = len(list((home / "hooks").glob("codex-*.sh")))
    summary["scripts"] = len(list((home / "scripts").glob("*.sh")))
    return summary


def jsonl_summary(path: Path) -> dict:
    total = 0
    invalid = 0
    last = None
    if path.exists():
        for line in path.read_text(encoding="utf-8", errors="ignore").splitlines():
            if not line.strip():
                continue
            total += 1
            try:
                last = json.loads(line)
            except Exception:
                invalid += 1
    return {"exists": path.exists(), "total": total, "invalid": invalid, "last": last}


def gate_summary(cwd: Path) -> dict:
    visible = cwd / ".codex-lattice" / "model-visible"
    names = [
        "MAJOR_ERRORS.md",
        "REFLECTION_REQUIRED.md",
        "DOCS_AGENT_REQUIRED.md",
        "SIMPLIFY_REQUIRED.md",
        "CONTEXT_PACKET.md",
        "REVIEW_PACKET.md",
    ]
    return {name: (visible / name).exists() for name in names}


def scheduler_summary() -> dict:
    plist = Path.home() / "Library" / "LaunchAgents" / "com.codex-lattice.healthcheck.plist"
    active = bool(run(Path.home(), ["launchctl", "list"]).find("com.codex-lattice.healthcheck") >= 0)
    return {"plist": str(plist), "installed": plist.exists(), "active": active}


def write_health(cwd: Path, data: dict) -> Path:
    now = datetime.datetime.now(datetime.timezone.utc)
    ts = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    harness = cwd / ".codex-lattice"
    visible = harness / "model-visible"
    visible.mkdir(parents=True, exist_ok=True)
    reports = harness / "reports"
    events = jsonl_summary(harness / "logs" / "events.jsonl")
    docs_queue = jsonl_summary(harness / "docs-sync-queue.jsonl")
    commits = sorted((harness / "commits").glob("*.json")) if (harness / "commits").exists() else []
    report_files = sorted(reports.glob("*latest*")) if reports.exists() else []
    codex = codex_config_summary()
    gates = gate_summary(cwd)
    scheduler = scheduler_summary()

    issues = []
    if not codex.get("features", {}).get("hooks"):
        issues.append("Codex hooks feature is not enabled")
    if codex.get("features", {}).get("codex_hooks") is not None:
        issues.append("Deprecated features.codex_hooks is present")
    if events["invalid"]:
        issues.append(f"event log has {events['invalid']} invalid JSONL lines")
    if gates.get("MAJOR_ERRORS.md"):
        issues.append("major error log is present; inspect before retrying failed work")
    if gates.get("DOCS_AGENT_REQUIRED.md"):
        issues.append("docs gate is present; reconcile docs before final review")
    if gates.get("SIMPLIFY_REQUIRED.md"):
        issues.append("simplify gate is present; consider simplification before final review")

    payload = {
        "ts": ts,
        "cwd": str(cwd),
        "codex": codex,
        "events": events,
        "docs_queue": docs_queue,
        "gates": gates,
        "scheduler": scheduler,
        "commit_logs": len(commits),
        "latest_reports": [str(path.relative_to(cwd)) for path in report_files if path.is_file()],
        "issues": issues,
    }

    json_out = harness / "harness-health-latest.json"
    json_out.write_text(json.dumps(payload, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")

    issue_text = "\n".join(f"- {issue}" for issue in issues) if issues else "- none"
    gate_text = "\n".join(f"- `{name}`: {'present' if present else 'absent'}" for name, present in gates.items())
    report_text = "\n".join(f"- `{path}`" for path in payload["latest_reports"]) or "- none"
    content = f"""# Harness Health

Generated: {ts}

## Codex Install

```json
{json.dumps(codex, ensure_ascii=False, indent=2, sort_keys=True)}
```

## Runtime Signals
- event log exists: {events["exists"]}
- event count: {events["total"]}
- invalid event lines: {events["invalid"]}
- docs queue entries: {docs_queue["total"]}
- commit logs: {len(commits)}

## Gates
{gate_text}

## Scheduler
- installed: {scheduler["installed"]}
- active: {scheduler["active"]}
- plist: `{scheduler["plist"]}`

## Latest Reports
{report_text}

## Attention Items
{issue_text}

## Rule
This file is a health signal. It is not source of truth. Verify against config, hooks, git diff, and command output.
"""
    out = visible / "HARNESS_HEALTH.md"
    out.write_text(content.rstrip() + "\n", encoding="utf-8")
    print(out)
    return out


data = load_input()
cwd = resolve_cwd(data)
write_health(cwd, data)
PY
