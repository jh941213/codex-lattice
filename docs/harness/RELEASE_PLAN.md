# Release Plan

## Version

- README displays version `0.0.1`.

## Rollout

- Merge through PR, then users pull and rerun `bash install.sh --ko` or `bash install.sh --en`.
- Before merge, run release readiness and confirm docs, validation, rollback, supply-chain, data, cost, and operator notes are current.

## Backout

- Revert the release commit and reinstall the previous version.

## User/Operator Notes

- New hook registrations may require `/hooks` trust review once after install.
- The new operations/governance skills are advisory workflows; they do not mutate cloud resources or release artifacts automatically.
