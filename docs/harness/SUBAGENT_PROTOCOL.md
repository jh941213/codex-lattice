# Subagent Protocol

This protocol defines how Codex Lattice uses sub-agents for coding work.
It is inspired by proven fresh-context delegation patterns, but it stays Codex-native.

## Core Rule

The parent agent owns orchestration. Sub-agents execute bounded work with explicitly supplied context; they do not inherit hidden session history or decide the overall plan.

## When To Use

- Use sub-agents when the task has a written plan or clearly separable work units.
- Use one implementer per task when file ownership is narrow and acceptance criteria are explicit.
- Use parallel sub-agents only when write scopes are disjoint and the next parent step is not blocked on all results.
- Keep work local when the task is tightly coupled, ambiguous, or the parent must make product/security/git decisions immediately.

## Parent Preparation

Before dispatching, the parent must prepare:

- task name and objective
- exact files or module ownership
- relevant requirements copied into the prompt
- acceptance criteria
- constraints and non-goals
- verification commands
- expected report format

Use `.codex-lattice/model-visible/CONTEXT_PACKET.md` as a retrieval aid when it exists, but copy only the relevant task context into the sub-agent prompt. Do not pass hidden logs or entire packet histories to sub-agents by default.

Do not make a sub-agent read a long plan file to discover its own job. The parent reads the plan, extracts the task, and gives the sub-agent the full task text plus only the context it needs.

## Implementer Prompt Contract

Implementer sub-agents must receive:

```md
## Task
- name:
- objective:
- owned files:
- do not edit:

## Context
- why this task exists:
- dependencies:
- relevant docs:

## Acceptance Criteria
- ...

## Verification
- commands:

## Report Format
- Status: DONE | DONE_WITH_CONCERNS | NEEDS_CONTEXT | BLOCKED
- Files changed:
- Verification run:
- Self-review:
- Concerns:
```

## Status Handling

- `DONE`: proceed to review.
- `DONE_WITH_CONCERNS`: read the concerns before review; resolve correctness or scope doubts before moving on.
- `NEEDS_CONTEXT`: provide the missing context and re-dispatch with the same or narrower task.
- `BLOCKED`: change the conditions before retrying: provide context, choose a stronger model/agent, split the task, or escalate to the user if the plan is wrong.

Never ignore an escalation. A stuck sub-agent is a signal that the parent prompt, scope, model, or plan needs to change.

## Review Order

Use review as two separate checks when code was written by a sub-agent:

1. **Spec compliance review:** verify that the actual diff implements exactly what was requested, with no missing or extra behavior.
2. **Code quality review:** after spec compliance passes, check maintainability, tests, security, simplicity, and integration risk.

The reviewer must inspect the real diff and source files. Do not accept the implementer's report as evidence.

## Review Prompt Contract

Review sub-agents must receive:

- what was requested
- what the implementer claims changed
- base/head commits or an explicit diff range
- files to inspect
- required verdict format

Verdict format:

```md
## Verdict
- Spec compliant: yes/no
- Ready to continue: yes/no

## Findings
- severity:
- file:line:
- issue:
- fix:
```

## Parallel Dispatch Rules

- Parallelize read-only investigation freely when questions are independent.
- Parallelize implementation only with disjoint write scopes.
- Tell every worker that other agents may be editing the repository and that they must not revert unrelated changes.
- Assign ownership in the prompt and require a changed-file list in the report.
- Integrate results in the parent after all relevant workers return.

## Final Integration

Before HITL, PR, merge, or final response:

- reconcile sub-agent reports with the actual git diff
- inspect `.codex-lattice/model-visible/REVIEW_PACKET.md` and `HARNESS_HEALTH.md` when present
- run verification from the parent session
- resolve `REFLECTION_REQUIRED.md`, `SIMPLIFY_REQUIRED.md`, and `DOCS_AGENT_REQUIRED.md`
- update `docs/harness/VALIDATION.md`, `TASKS.md`, and `CHANGELOG.md`
- record unresolved sub-agent concerns in `RISKS.md`
