---
name: eval
description: "Evaluate code output across functional correctness, code quality, simplicity, and usability/security. Triggers on: eval, evaluation, quality score, code evaluation. NOT for: implementation or general review."
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Bash, Grep, Glob
---

# Code Eval

Run an independent evaluation of the current output.

## Step 1: Use Evaluator

Use the Codex custom agent `evaluator` only when the user explicitly requests sub-agents or the active Codex instructions allow delegation.

Evaluation prompt:

```text
Evaluate the current changes independently.
Score out of 100 across functional correctness, code quality, simplicity, and usability/security.
Accept only git diff, test/build output, and file references as evidence.
Return PASS / CONDITIONAL / FAIL and the smallest fix-forward loop.
```

## Step 2: Report

```text
Eval result: [PASS/CONDITIONAL/FAIL] - [N]/100

Functional correctness: [N]/40
Code quality: [N]/25
Simplicity: [N]/20
Usability & security: [N]/15

[Summary of required fixes]
```

## Step 3: Re-evaluate

For CONDITIONAL or FAIL, describe concrete fixes and ask whether to run another evaluation pass after changes.
