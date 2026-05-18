#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${CODEX_LATTICE_REPORT_DIR:-$ROOT/.codex-lattice/reports}"
USE_CODEX="${CODEX_LATTICE_USE_CODEX:-0}"
mkdir -p "$OUT_DIR"

HEALTH_MD="$("$ROOT/scripts/codex-lattice-healthcheck.sh" "$OUT_DIR")"
LOG_MD="$("$ROOT/scripts/codex-lattice-log-analyze.sh" "$OUT_DIR")"
TS="$(date -u +%Y%m%d-%H%M%S)"
REPORT="$OUT_DIR/scheduled-report-$TS.md"
LATEST="$OUT_DIR/scheduled-report-latest.md"

if [ "$USE_CODEX" = "1" ]; then
	codex exec \
		--cd "$ROOT" \
		--sandbox read-only \
		--ask-for-approval never \
		--output-last-message "$REPORT" \
		"Read only these generated summaries: $HEALTH_MD and $LOG_MD. Produce a concise operations report with health status, risks, and recommended human follow-up. Do not modify files."
else
	{
		printf "# Codex Lattice Scheduled Report\n\n"
		printf -- "- generated: %s\n" "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
		printf -- "- codex summary: disabled. Set CODEX_LATTICE_USE_CODEX=1 to enable read-only Codex report generation.\n\n"
		printf "## Healthcheck\n\n"
		cat "$HEALTH_MD"
		printf "\n## Log Analysis\n\n"
		cat "$LOG_MD"
	} >"$REPORT"
fi

cp "$REPORT" "$LATEST"
printf "%s\n" "$REPORT"
