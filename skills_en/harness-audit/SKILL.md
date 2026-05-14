---
name: harness-audit
description: "Audit overall harness health across hooks, skills, agents, rules, docs, evaluation, and observability. Triggers on: harness audit, harness diagnostics, setup check. NOT for: implementation."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Glob
---

# Harness Health Audit

Audit the Codex harness across eight dimensions.

## Dimensions

| Dimension | Score | Evidence |
|-----------|-------|----------|
| AGENTS.md quality | 0-3 | Entry point, map, constraints |
| Skills coverage | 0-3 | Skill count, triggers, anti-triggers |
| Agents architecture | 0-3 | Role separation and custom-agent schema |
| Hooks automation | 0-3 | Lifecycle hooks, blocking checks, logging |
| Rules structure | 0-3 | File-pattern rules and security/performance guidance |
| MCP/tools | 0-3 | External tools, docs, search, code analysis |
| Eval pipeline | 0-3 | Verification, scoring, independent reviewer |
| Multi-agent process | 0-3 | Delegation rules, ownership, docs sync |

## Process

1. Scan the project root and `~/.codex/` if available.
2. Check `AGENTS.md`, `.codex/config.toml`, `.codex/agents/*.toml`, `skills*/`, `rules*/`, `hooks/`, and `docs/harness/`.
3. Score each dimension from 0 to 3.
4. Return total score out of 24 plus the top three improvements.

## Output

```markdown
# Harness Audit

## Score
Total: [N]/24

| Dimension | Score | Evidence |
|-----------|-------|----------|
| AGENTS.md | [N]/3 | ... |

## Top Improvements
1. ...
2. ...
3. ...
```
