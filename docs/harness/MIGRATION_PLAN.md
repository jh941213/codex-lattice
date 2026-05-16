# Migration Plan

## Compatibility

- Installer removes the previous managed config block before writing the current one.
- `features.codex_hooks` is removed in favor of `features.hooks`.

## Data Migration

- No application data migration is required.
- Runtime folder identity moved from `.codex-harness/` to `.codex-lattice/`.

## Rollback

- Revert the install commit and rerun `bash install.sh --ko` or `bash install.sh --en`.
- Restore previous `~/.codex/config.toml` from backup if needed.

## Verification

- Run temp install, config parse, hook syntax checks, integration checker, and gitleaks.
