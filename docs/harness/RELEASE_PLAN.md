# Release Plan

## Version

- README displays version `0.01`.

## Rollout

- Merge through PR, then users pull and rerun `bash install.sh --ko` or `bash install.sh --en`.

## Backout

- Revert the release commit and reinstall the previous version.

## User/Operator Notes

- New hook registrations may require `/hooks` trust review once after install.
