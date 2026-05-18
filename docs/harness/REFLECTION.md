# Reflection Protocol

Use this file when the user gives sequential work, corrects direction, resumes after compaction, or asks for several outcomes in one turn.

## Core Rule

The newest user request wins. Do not keep executing an older task just because it was already in motion.

## When To Read

- Before starting multi-step or mixed-scope work.
- After the user interrupts, corrects direction, or asks "is this done?"
- After context compaction or a resumed session.
- Before HITL, PR creation, merge, or final response.

## Instruction Ledger

Maintain this ledger mentally or in the working notes before editing:

```md
## Instruction Ledger
- newest request:
- ordered steps:
- non-negotiables:
- dependencies:
- current step:
- blocked or ambiguous:
- completion criteria:
- final response must mention:
```

## Drift Checks

- Am I answering the newest request, or an older session goal?
- Did the user ask for ordering such as first, then, finally, commit, push, PR, or merge?
- Did I skip a required install, verification, documentation, or local-apply step?
- Am I changing unrelated files because they are nearby?
- Am I creating a branch, PR, or merge without the user asking for that level of git action?
- If using sub-agents, did I give each one bounded context, file ownership, acceptance criteria, and a report format?
- Did I verify sub-agent claims against the actual diff before continuing?
- Did code changes also update `docs/harness/` and validation evidence?
- Did simplify, docs, security, and reflection gates resolve before handoff?

## Before Final Response

- Re-read the latest user message.
- Confirm every requested action is done, skipped with a reason, or explicitly blocked.
- Verify the repo state, branch, commit, push, and PR/merge status if git actions were part of the request.
- Keep the final answer focused on completed work and remaining concrete risks.

## Ambiguity Rule

If a safe local convention exists, choose it and record the assumption in docs. Ask the user only when the missing decision changes product behavior, cost, security, data loss risk, or repository history.
