---
name: finops-azure
description: "Azure FinOps and resource review workflow. Use when Azure resources, infrastructure specs, cost estimates, budgets, quotas, scaling, monitoring, or cloud operations are involved. Defaults to read-only Azure CLI discovery."
---

# FinOps Azure

Use this skill when Azure resources, infra specs, cost estimates, budgets, quotas, scaling, monitoring, or cloud operations are involved.

## Workflow

1. Use read-only `az` commands by default.
2. Confirm login and subscription:
   - `az account show --output json`
   - `az account list --output table`
3. Inventory relevant resources:
   - `az resource list --output json`
   - filter by resource group, tag, or service when known
4. Check cost and waste signals:
   - budgets
   - unattached disks
   - idle public IPs
   - oversized SKUs
   - missing autoscale
   - missing tags
5. Check operational signals:
   - diagnostic settings
   - alerts
   - metrics
   - backup/restore posture
6. Record durable assumptions in `.codex-lattice/model-visible/AZURE_INFRA_MEMORY.md`.
7. Update `docs/harness/COST_MODEL.md`, `docs/harness/INFRA_SPEC.md`, and `docs/harness/OPERATIONS_RUNBOOK.md`.

## Safety Rules

- Do not create, update, delete, scale, rotate, or restart Azure resources without explicit user approval.
- Never print secrets, keys, connection strings, tokens, or full credentials.
- Prefer JSON output for machine-readable evidence.

## Required Output

Return subscription, resource scope, cost drivers, waste candidates, monitoring gaps, risk, and next commands.
