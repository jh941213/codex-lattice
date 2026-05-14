---
name: autodev
description: >
  Codex autonomous code experimentation loop. Codex modifies code, validates, records evidence, and keeps changes only when they pass explicit criteria.
  Applies Karpathy's autoresearch pattern to general software development.
  Triggers: "autodev", "autonomous development", "autonomous experimentation", "run overnight", "/goal", "goal-based auto optimization"
  Anti-triggers: "implement it yourself", "do it once", "manual"
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# AutoDeveloper -- Autonomous Code Experimentation Loop

Autoresearch pattern adapted for Codex: modify code, validate, record evidence, keep/discard by explicit criteria.
Use Codex `/goal` for the long-running objective and done condition. This harness does not rely on hidden stop hooks or destructive reset loops.

## Phase 0: Configuration Collection

Confirm the following with the user (only ask about missing items):

```yaml
goal: "What to achieve"                # e.g., "Reduce API response time by 50%"
done_when: "How to know it is done"     # e.g., "All checklist items done and npm test passes"
scope: ["Modifiable file patterns"]    # e.g., ["src/api/**", "src/utils/**"]
metric: "Evaluation command"           # e.g., "npm test" or "npm run bench"
budget: 20                             # Maximum number of experiments (default 20)
mode: "single"                         # single | parallel (default single)
```

### Automatic Metric Detection

If the user does not provide a metric, analyze the project and auto-configure:
1. `package.json` -> `npm test` or `vitest run` or `jest`
2. `pyproject.toml` -> `pytest`
3. `Makefile` -> `make test`
4. If a benchmark script exists -> suggest that command

## Phase 1: Establish Baseline

First attach the objective to the Codex thread:

```text
/goal {goal}; done_when={done_when}; scope={scope}; metric={metric}; docs=docs/harness/*
```

Record the current state before starting experiments:

```bash
# 1. Create autodev branch from current branch
git checkout -b autodev/$(date +%Y%m%d-%H%M)

# 2. Run baseline verification
mkdir -p .codex-harness/autodev
{metric_command} > .codex-harness/autodev/baseline.log 2>&1

# 3. Record baseline result
echo "baseline captured" > .codex-harness/autodev/score.txt

# 4. Initialize results.tsv
echo -e "experiment\tcommit\tscore\tstatus\tdescription" > .codex-harness/autodev/results.tsv
```

### .codex-harness/autodev/ Directory Structure

```
.codex-harness/autodev/
  results.tsv      # Experiment result log (autoresearch's results.tsv)
  baseline.log     # Baseline execution log
  run.log          # Current experiment execution log
  ideas.md         # List of ideas to try
```

Add `.codex-harness/autodev/` to `.gitignore`.

## Phase 2: Idea Generation

Read files within scope and create a list of improvement ideas aligned with the goal.

Record in `.codex-harness/autodev/ideas.md`:

```markdown
# Experiment Ideas

## Pending
- [ ] Idea 1: Description
- [ ] Idea 2: Description
...

## Completed
- [x] Idea N: Description -> keep (score: 85)
- [x] Idea M: Description -> discard (score: 40)
```

When ideas run out:
1. Try combining existing kept changes
2. Re-read scope files and find new angles
3. Try simplifying kept code

## Phase 3: Experiment Loop (LOOP)

Continue until the budget is exhausted, the goal is achieved, or validation fails in a way that needs human judgment.

```
LOOP (experiment = 1 to budget):

  1. SNAPSHOT
     git_snapshot=$(git rev-parse HEAD)

  2. MODIFY
     - Select the next idea from ideas.md
     - Only modify files within scope
     - Do not modify files outside scope

  3. COMMIT
     git add [specific-files]
     git commit -m "[autodev] exp-{N}: {description}"

  4. VERIFY
     {metric_command} > .codex-harness/autodev/run.log 2>&1
     EXIT_CODE=$?

  5. SCORE
     Determine score from the configured metric and validation output.

  6. JUDGE
     if SCORE == -999:
       # CRASH -- attempt recovery
       Apply build-fix skill once
       Re-run -> if still failing, DISCARD
     elif SCORE > BEST_SCORE:
       # KEEP -- advance branch
       BEST_SCORE = SCORE
       STATUS = "keep"
     else:
       # DISCARD -- do not commit this experiment
       Stop and report the diff. Do not run destructive reset without explicit user approval.
       STATUS = "discard"

  7. LOG
     Append one line to results.tsv:
     {experiment}\t{commit}\t{SCORE}\t{STATUS}\t{description}

     Update ideas.md (check mark + result)

  8. CONTINUE
     Proceed to next idea
```

## Scoring Function

Score from the configured metric, test output, and validation evidence. Suggested scoring criteria:

| Condition | Score |
|-----------|-------|
| Build failure | -999 (immediate discard) |
| Existing tests broken | -999 (immediate discard) |
| All tests pass | +100 |
| New tests passing | +10/each |
| Zero type errors | +50 |
| Zero lint errors | +20 |
| Performance improvement (if applicable) | +200 |
| Reduced lines of code | +0.1/line (simplicity bonus) |

## Phase 4: Completion Report

When budget is exhausted or the `/goal` done condition is achieved:

```markdown
# AutoDev Experiment Report

## Summary
- Total experiments: {N}
- Keep: {K} / Discard: {D} / Crash: {C}
- Baseline score: {baseline}
- Final score: {best}
- Improvement: {improvement}%

## Kept Experiments
| # | Description | Score Change |
|---|-------------|-------------|
| 3 | Added cache layer | 45 -> 85 |
| 7 | Query batching | 85 -> 120 |

## Final Branch
autodev/{tag} -- ready to merge into main

## Detailed Log
See .codex-harness/autodev/results.tsv
```

## Safety Measures

1. **No modifications outside scope**: Only modify files/directories specified in scope
2. **Existing test protection**: Unconditionally discard if existing tests break
3. **Crash recovery limit**: Only one build-fix attempt. Give up after 2+ failures
4. **Git safety**: All experiments only on autodev/ branches. Never touch main
5. **.codex-harness/autodev/ not tracked**: Added to .gitignore

## Leveraging Existing Skills

| Situation | Skill Used |
|-----------|------------|
| Recovery on build failure | `build-fix` |
| Code cleanup after keep | `simplify` |
| Test-based experimentation | `tdd` |
| Experiment idea generation | `plan` (planner agent) |
| Final verification | `verify` |

## Codex Built-ins

- `/goal`: objective, done condition, pause/resume/clear state
- `/plan`: short-lived planning before promoting a plan into docs
- `/review` and `/diff`: inspect changes before heavier review workflows
- `/compact`: summarize long-running context before resuming
