# Scheduler

Codex does not provide a built-in cron scheduler. Codex Lattice scheduled operations use external schedulers to run local scripts.

## Default

- Scheduled operations are off by default.
- Enabling is explicit.
- Disabling removes the launchd registration.
- The default scheduled report does not call a model.

## Commands

```bash
# run once, deterministic report only
./scripts/codex-lattice-scheduler.sh run

# enable macOS launchd hourly schedule
./scripts/codex-lattice-scheduler.sh enable

# inspect schedule registration
./scripts/codex-lattice-scheduler.sh status

# disable schedule
./scripts/codex-lattice-scheduler.sh disable
```

## Optional Codex Summary

Set `CODEX_LATTICE_USE_CODEX=1` to let `codex exec` summarize generated healthcheck and log-analysis files.

```bash
CODEX_LATTICE_USE_CODEX=1 ./scripts/codex-lattice-scheduler.sh run
```

Safety policy:

- `codex exec` uses `--sandbox read-only`.
- `codex exec` uses `--ask-for-approval never`.
- The prompt instructs Codex not to modify files.
- Shell scripts produce the source healthcheck/log-analysis evidence first; Codex only summarizes those generated files.

## Output

Reports are written under `.codex-lattice/reports/`:

- `health-latest.json`
- `health-latest.md`
- `log-analysis-latest.json`
- `log-analysis-latest.md`
- `scheduled-report-latest.md`
- `scheduled-report-YYYYMMDD-HHMMSS.md`

Scheduler process logs are written under `.codex-lattice/logs/`:

- `scheduler.out.log`
- `scheduler.err.log`

## Schedules

macOS launchd:

```bash
CODEX_LATTICE_INTERVAL_SECONDS=3600 ./scripts/codex-lattice-scheduler.sh enable
```

Cron and systemd examples live in `ops/scheduler/`.

## Operational Rules

- Do not schedule automatic code edits, commits, pushes, releases, or cloud mutations.
- Use scheduled operations for healthcheck, monitoring, log analysis, and human follow-up reports.
- Keep `CODEX_LATTICE_USE_CODEX=0` for low-cost deterministic checks.
- Use `CODEX_LATTICE_USE_CODEX=1` only when a model-written narrative report is worth the cost.
