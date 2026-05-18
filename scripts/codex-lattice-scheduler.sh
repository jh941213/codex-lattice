#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LABEL="${CODEX_LATTICE_LAUNCHD_LABEL:-com.codex-lattice.healthcheck}"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
INTERVAL="${CODEX_LATTICE_INTERVAL_SECONDS:-3600}"
USE_CODEX="${CODEX_LATTICE_USE_CODEX:-0}"

usage() {
	cat <<EOF
Usage: $0 <enable|disable|status|run>

Environment:
  CODEX_LATTICE_INTERVAL_SECONDS  launchd interval in seconds (default: 3600)
  CODEX_LATTICE_USE_CODEX         1 enables read-only codex exec summary, 0 uses deterministic report only
  CODEX_LATTICE_REPORT_DIR        report output directory
EOF
}

enable() {
	mkdir -p "$(dirname "$PLIST")" "$ROOT/.codex-lattice/reports" "$ROOT/.codex-lattice/logs"
	cat >"$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>$ROOT/scripts/codex-lattice-scheduled-report.sh</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$ROOT</string>
  <key>EnvironmentVariables</key>
  <dict>
    <key>CODEX_LATTICE_USE_CODEX</key>
    <string>$USE_CODEX</string>
  </dict>
  <key>StartInterval</key>
  <integer>$INTERVAL</integer>
  <key>RunAtLoad</key>
  <true/>
  <key>StandardOutPath</key>
  <string>$ROOT/.codex-lattice/logs/scheduler.out.log</string>
  <key>StandardErrorPath</key>
  <string>$ROOT/.codex-lattice/logs/scheduler.err.log</string>
</dict>
</plist>
EOF
	launchctl unload "$PLIST" >/dev/null 2>&1 || true
	launchctl load "$PLIST"
	printf "enabled %s\n" "$PLIST"
}

disable() {
	launchctl unload "$PLIST" >/dev/null 2>&1 || true
	rm -f "$PLIST"
	printf "disabled %s\n" "$PLIST"
}

status() {
	if [ -f "$PLIST" ]; then
		printf "installed: %s\n" "$PLIST"
	else
		printf "not installed: %s\n" "$PLIST"
	fi
	launchctl list 2>/dev/null | grep -F "$LABEL" || true
}

case "${1:-}" in
enable) enable ;;
disable) disable ;;
status) status ;;
run) "$ROOT/scripts/codex-lattice-scheduled-report.sh" ;;
*)
	usage
	exit 2
	;;
esac
