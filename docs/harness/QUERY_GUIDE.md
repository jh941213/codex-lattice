# Query Guide

Use this file with `DATA_MODEL.md` when writing or reviewing database queries.

## Data Model Source

- Canonical schema/data model:
- Migration directory:
- ORM/query builder conventions:
- Read/write ownership:

## Query Standards

- Use parameterized queries only.
- Select only required columns.
- Define deterministic ordering for pagination.
- Avoid N+1 reads; batch or join deliberately.
- Include tenant/user authorization predicates at the data boundary.
- Consider timeout, retry, idempotency, transaction, and isolation requirements.

## Performance Review

- Expected cardinality:
- Required indexes:
- Join/filter order:
- Pagination strategy:
- Cache/read model considerations:
- EXPLAIN plan evidence, when available:

## Safety Review

- PII fields touched:
- Authorization predicates:
- Mutation rollback:
- Race/locking risks:
- Audit fields:

## Validation Cases

- Empty result:
- Single row:
- High-cardinality page:
- Permission boundary:
- Concurrent write/read:
