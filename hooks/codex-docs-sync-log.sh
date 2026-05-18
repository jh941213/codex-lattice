#!/usr/bin/env bash
set -uo pipefail

INPUT="$(cat 2>/dev/null || true)"

CODEX_HOOK_INPUT="$INPUT" /usr/bin/python3 - <<'PY'
import datetime
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

changed = set(filter(None, run(cwd, ["git", "diff", "--name-only"]).splitlines()))
changed.update(filter(None, run(cwd, ["git", "diff", "--cached", "--name-only"]).splitlines()))
changed = sorted(changed)
if not changed:
    raise SystemExit(0)

def is_code_file(path):
    suffix = Path(path).suffix.lower()
    return suffix in CODE_EXTENSIONS and not path.startswith((".codex-lattice/", "docs/harness/"))

def needs_docs_gate(path):
    return not path.startswith((".codex-lattice/", "docs/harness/"))

def classify_docs(paths):
    required = {"CHANGELOG.md", "VALIDATION.md", "TASKS.md"}
    for path in paths:
        low = path.lower()
        suffix = Path(path).suffix.lower()
        if is_code_file(path):
            required.update({"PRODUCT_BRIEF.md", "FEATURE_SPEC.md", "TEST_PLAN.md", "SECURITY_POLICY.md"})
        if any(token in low for token in ("api", "route", "controller", "endpoint", "openapi", "swagger", "schema")):
            required.update({"API_SPEC.md", "SECURITY_POLICY.md", "TEST_PLAN.md"})
        if suffix in {".tf", ".tfvars", ".bicep", ".yaml", ".yml"} or any(token in low for token in ("infra", "terraform", "bicep", "k8s", "kubernetes", "helm", "docker", "compose", "azure", "cloud")):
            required.update({"INFRA_SPEC.md", "OBSERVABILITY.md", "OPERATIONS_RUNBOOK.md", "SECURITY_POLICY.md", "RELEASE_PLAN.md"})
        if any(token in low for token in ("db", "database", "schema", "model", "entity", "migration", "prisma", "typeorm", "sql", "drizzle")):
            required.update({"DATA_MODEL.md", "MIGRATION_PLAN.md", "TEST_PLAN.md"})
        if suffix in {".tsx", ".jsx", ".css", ".scss", ".sass", ".vue", ".svelte"} or any(token in low for token in ("ui", "ux", "component", "page", "screen", "view")):
            required.update({"UX_SPEC.md", "TEST_PLAN.md"})
        if any(token in low for token in ("auth", "security", "permission", "role", "secret", "token", "credential", ".env")):
            required.add("SECURITY_POLICY.md")
        if any(token in low for token in ("package.json", "version", "release", "deploy", "ci", "workflow", "changelog")):
            required.update({"RELEASE_PLAN.md", "OPERATIONS_RUNBOOK.md"})
        if any(token in low for token in ("monitor", "metric", "alert", "log", "runbook", "slo", "incident", "ops", "operation")):
            required.update({"OBSERVABILITY.md", "OPERATIONS_RUNBOOK.md", "SLO_POLICY.md", "INCIDENT_RESPONSE.md", "POSTMORTEM_TEMPLATE.md"})
        if any(token in low for token in ("sbom", "slsa", "supply", "dependency", "license", "provenance", "package.json", "package-lock", "pnpm-lock", "yarn.lock", "requirements.txt", "pyproject.toml", "uv.lock", "poetry.lock", "cargo.toml", "cargo.lock", "go.mod", "go.sum")):
            required.update({"SUPPLY_CHAIN.md", "SECURITY_POLICY.md", "RELEASE_PLAN.md"})
        if any(token in low for token in ("privacy", "pii", "retention", "gdpr", "compliance", "data-governance", "classification")):
            required.update({"DATA_GOVERNANCE.md", "SECURITY_POLICY.md", "DATA_MODEL.md"})
        if any(token in low for token in ("agent", "mcp", "tool", "hook", "plugin", "prompt", "subagent", "sub-agent")):
            required.update({"AGENT_SECURITY.md", "SECURITY_POLICY.md", "SUBAGENT_PROTOCOL.md"})
        if any(token in low for token in ("cost", "budget", "finops", "azure", "resource", "quota")):
            required.update({"COST_MODEL.md", "INFRA_SPEC.md", "OPERATIONS_RUNBOOK.md"})
    return sorted(required)

required_docs = classify_docs(changed)

docs = cwd / "docs" / "harness"
docs.mkdir(parents=True, exist_ok=True)
for name, content in {
    "README.md": "# Harness Docs\n\nModel-visible docs for Codex coding work.\n",
    "TASKS.md": "# Tasks\n\n- [ ] Keep this file aligned with current implementation work.\n",
    "DECISIONS.md": "# Decisions\n\n",
    "CHANGELOG.md": "# Harness Changelog\n\n## Unreleased\n\n",
    "VALIDATION.md": "# Validation\n\n",
    "RISKS.md": "# Risks\n\n",
    "PRODUCT_BRIEF.md": "# Product Brief\n\n## Problem\n\n## Users\n\n## Scope\n\n## Non-Goals\n\n## Open Questions Before PRD\n\n",
    "FEATURE_SPEC.md": "# Feature Spec\n\n## Current Behavior\n\n## Intended Behavior\n\n## Acceptance Criteria\n\n",
    "API_SPEC.md": "# API Spec\n\n## Endpoints\n\n## Request/Response Shapes\n\n## Validation And Errors\n\n",
    "INFRA_SPEC.md": "# Infra Spec\n\n## Resources\n\n## Configuration\n\n## Operations And Monitoring\n\n",
    "SECURITY_POLICY.md": "# Security Policy\n\n## Trust Boundaries\n\n## Auth And Authorization\n\n## Data Handling\n\n## Secret Handling\n\n## Abuse And Failure Modes\n\n",
    "DATA_MODEL.md": "# Data Model\n\n## Entities\n\n## Ownership\n\n## Persistence\n\n## Normalization Rules\n\n",
    "TEST_PLAN.md": "# Test Plan\n\n## Unit\n\n## Integration\n\n## E2E\n\n## Regression\n\n## Manual Checks\n\n",
    "OBSERVABILITY.md": "# Observability\n\n## Logs\n\n## Metrics\n\n## Alerts\n\n## Dashboards\n\n## Incident Signals\n\n",
    "OPERATIONS_RUNBOOK.md": "# Operations Runbook\n\n## SLOs\n\n## Monitoring Checklist\n\n## Alert Response\n\n## Rollback\n\n## Incident Review\n\n",
    "SLO_POLICY.md": "# SLO Policy\n\n## Service Level Indicators\n\n## Objectives\n\n## Error Budget\n\n## Release Freeze Policy\n\n",
    "INCIDENT_RESPONSE.md": "# Incident Response\n\n## Severity Levels\n\n## Triage\n\n## Mitigation\n\n## Communication\n\n## Follow-Up\n\n",
    "POSTMORTEM_TEMPLATE.md": "# Postmortem Template\n\n## Summary\n\n## Impact\n\n## Timeline\n\n## Root Causes\n\n## Corrective Actions\n\n",
    "SUPPLY_CHAIN.md": "# Supply Chain\n\n## Dependency Policy\n\n## SBOM\n\n## Provenance\n\n## Vulnerability Handling\n\n",
    "AGENT_SECURITY.md": "# Agent Security\n\n## Tool Trust Boundaries\n\n## Prompt Injection Risks\n\n## Excessive Agency Controls\n\n## Secret Exposure Controls\n\n",
    "DATA_GOVERNANCE.md": "# Data Governance\n\n## Classification\n\n## Retention\n\n## Access\n\n## Privacy Review\n\n",
    "COST_MODEL.md": "# Cost Model\n\n## Cost Drivers\n\n## Budgets\n\n## Azure Resource Review\n\n## Waste Reduction\n\n",
    "MIGRATION_PLAN.md": "# Migration Plan\n\n## Compatibility\n\n## Data Migration\n\n## Rollback\n\n## Verification\n\n",
    "RELEASE_PLAN.md": "# Release Plan\n\n## Version\n\n## Rollout\n\n## Backout\n\n## User/Operator Notes\n\n",
    "UX_SPEC.md": "# UX Spec\n\n## Primary Flow\n\n## States\n\n## Accessibility\n\n## Responsive Behavior\n\n",
}.items():
    p = docs / name
    if not p.exists():
        p.write_text(content, encoding="utf-8")

entry = {
    "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "changed_files": changed,
    "docs_dir": "docs/harness",
    "required_docs": required_docs,
    "docs_agent_required": any(needs_docs_gate(path) for path in changed),
    "instruction": "Reconcile docs/harness before final response; use docs_maintainer only when agent delegation is explicitly allowed.",
}
harness = cwd / ".codex-lattice"
harness.mkdir(parents=True, exist_ok=True)
with (harness / "docs-sync-queue.jsonl").open("a", encoding="utf-8") as f:
    f.write(json.dumps(entry, ensure_ascii=False, sort_keys=True) + "\n")

if entry["docs_agent_required"]:
    visible = harness / "model-visible"
    visible.mkdir(parents=True, exist_ok=True)
    docs_lines = "\n".join(f"- `docs/harness/{name}`" for name in required_docs)
    changed_lines = "\n".join(f"- `{path}`" for path in changed[:40])
    (visible / "DOCS_AGENT_REQUIRED.md").write_text(f"""# Docs Agent Required

Last updated: {entry["ts"]}

## Required Before HITL, Review, Or Final Response
- Spawn `docs_maintainer` when the current Codex run allows sub-agents.
- If sub-agents are not available, the parent agent must update the same docs directly.
- Keep product brief, feature specs, API specs, infra specs, security policy, agent security, data model, data governance, test plan, observability, SLO policy, operations runbook, incident response, postmortem, supply-chain, cost model, migration, release, UX, validation, risks, and changelog aligned with the actual diff.
- Do not ask for human review while docs are stale unless the task is blocked.

## Required Docs
{docs_lines}

## Changed Files
{changed_lines}
""", encoding="utf-8")
PY

exit 0
