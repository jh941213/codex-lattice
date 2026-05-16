# UX Spec

## Primary Flow

- Users clone the repo, install prerequisites, run installer, restart Codex, and trust hooks once.

## States

- Fresh install: hooks may show review required.
- Trusted install: `/hooks` should show matching installed and active counts.
- Missing integration: checker prints install guidance.

## Accessibility

- README content should remain readable in plain Markdown.
- Avoid visual-only instructions.

## Responsive Behavior

- README images should be optional context; installation must be understandable without images.
