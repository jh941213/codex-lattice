# Data Model

## Entities

- Codex Lattice has no application database entities.
- Runtime files are grouped under `.codex-lattice/` by responsibility: logs, commits, model-visible memory, and state.

## Ownership

- `docs/harness/` is model-visible work documentation.
- `.codex-lattice/logs/` is hidden operational telemetry.
- `.codex-lattice/model-visible/` contains files the model may need to read before retrying or handing off.
- `REFLECTION_REQUIRED.md` is a transient model-visible gate that points to `docs/harness/REFLECTION.md`.

## Persistence

- Runtime logs and generated gate files are ignored unless intentionally promoted to docs.

## Normalization Rules

- External config is normalized through installer-managed `~/.codex/config.toml` entries.
- Project docs should not duplicate hidden runtime logs.
- Query-specific standards, indexes, pagination, and validation cases belong in `QUERY_GUIDE.md` and should reference this data model instead of duplicating entity definitions.
