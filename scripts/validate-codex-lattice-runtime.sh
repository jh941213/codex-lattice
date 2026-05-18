#!/usr/bin/env bash
# shellcheck disable=SC2329
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
OUT_DIR="${1:-$ROOT/.codex-lattice/reports}"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
REPORT_JSON="$OUT_DIR/runtime-validation-latest.json"
REPORT_MD="$OUT_DIR/runtime-validation-latest.md"
FAILURES=0
mkdir -p "$OUT_DIR"

CHECKS_FILE="$(mktemp)"
TMP_ROOTS=()

cleanup() {
	rm -f "$CHECKS_FILE"
	if [ "${CODEX_LATTICE_KEEP_VALIDATION_TMP:-0}" != "1" ]; then
		for dir in "${TMP_ROOTS[@]:-}"; do
			rm -rf "$dir"
		done
	fi
}
trap cleanup EXIT

record_check() {
	local name="$1"
	local code="$2"
	local output="$3"
	local status="pass"
	if [ "$code" -ne 0 ]; then
		status="fail"
		FAILURES=1
	fi
	jq -n \
		--arg name "$name" \
		--arg status "$status" \
		--arg output "${output:0:8000}" \
		--argjson exit_code "$code" \
		'{name:$name,status:$status,exit_code:$exit_code,output:$output}' >>"$CHECKS_FILE"
}

run_check() {
	local name="$1"
	shift
	local output code
	set +e
	output="$("$@" 2>&1)"
	code=$?
	set -e
	record_check "$name" "$code" "$output"
	if [ "$code" -ne 0 ]; then
		printf "FAIL %s\n%s\n" "$name" "$output" >&2
	else
		printf "PASS %s\n" "$name"
	fi
}

hook_registry_check() {
	python3 - "$ROOT" <<'PY'
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
data = json.loads((root / "hooks" / "hooks.json").read_text(encoding="utf-8"))
expected_events = {
    "SessionStart",
    "UserPromptSubmit",
    "PreToolUse",
    "PostToolUse",
    "PermissionRequest",
    "PreCompact",
    "PostCompact",
    "Stop",
}
missing = expected_events - set(data)
if missing:
    raise SystemExit(f"missing events: {sorted(missing)}")

commands = []
for event, entries in data.items():
    if not isinstance(entries, list):
        raise SystemExit(f"{event} must be a list")
    for entry in entries:
        matcher = entry.get("matcher")
        hooks = entry.get("hooks")
        if not matcher or not isinstance(hooks, list) or not hooks:
            raise SystemExit(f"invalid hook entry under {event}: {entry}")
        for hook in hooks:
            if hook.get("type") != "command":
                raise SystemExit(f"non-command hook under {event}: {hook}")
            command = hook.get("command", "")
            if not command.startswith("bash ~/.codex/"):
                raise SystemExit(f"unexpected command path under {event}: {command}")
            rel = command.split("~/.codex/", 1)[1].split()[0]
            target = root / rel
            if not target.exists():
                raise SystemExit(f"registered command target missing: {rel}")
            commands.append((event, matcher, command))

if len(commands) != 27:
    raise SystemExit(f"expected 27 hook commands, got {len(commands)}")

required = {
    "bash ~/.codex/scripts/codex-lattice-context-packet.sh",
    "bash ~/.codex/scripts/codex-lattice-review-packet.sh",
    "bash ~/.codex/scripts/codex-lattice-harness-health.sh",
    "bash ~/.codex/hooks/codex-docs-sync-log.sh",
    "bash ~/.codex/hooks/codex-simplify-gate.sh Stop",
    "bash ~/.codex/hooks/codex-reflection-reminder.sh PostCompact",
}
registered = {command for _, _, command in commands}
missing_required = required - registered
if missing_required:
    raise SystemExit(f"missing required hook commands: {sorted(missing_required)}")

print(f"events={len(data)} commands={len(commands)}")
PY
}

skill_validation_check() {
	local validator="$CODEX_HOME/skills/.system/skill-creator/scripts/quick_validate.py"
	if [ -f "$validator" ] && command -v uv >/dev/null 2>&1; then
		local failed=0
		for dir in "$ROOT"/skills/*; do
			[ -d "$dir" ] || continue
			uv run --with pyyaml python "$validator" "$dir" >/tmp/codex-lattice-skill-validate.log 2>&1 || {
				cat /tmp/codex-lattice-skill-validate.log
				failed=1
			}
		done
		rm -f /tmp/codex-lattice-skill-validate.log
		[ "$failed" -eq 0 ]
	else
		ruby -ryaml -e '
          Dir[ARGV[0] + "/skills/*/SKILL.md"].sort.each do |f|
            text = File.read(f)
            m = text.match(/\A---\n(.*?)\n---\n/m) or abort("missing frontmatter: #{f}")
            data = YAML.safe_load(m[1], permitted_classes: [], aliases: false)
            abort("missing name: #{f}") unless data["name"]
            abort("missing description: #{f}") unless data["description"]
          end
        ' "$ROOT"
	fi
}

agent_toml_check() {
	python3 - "$ROOT" <<'PY'
import sys
from pathlib import Path
try:
    import tomllib
except Exception as exc:
    raise SystemExit(f"tomllib unavailable: {exc}")

root = Path(sys.argv[1])
agent_dir = root / ".codex" / "agents"
agents = sorted(agent_dir.glob("*.toml"))
if len(agents) != 15:
    raise SystemExit(f"expected 15 agent TOML files, got {len(agents)}")

names = set()
for path in agents:
    data = tomllib.loads(path.read_text(encoding="utf-8"))
    for key in ("name", "description", "developer_instructions"):
        if not data.get(key):
            raise SystemExit(f"{path} missing {key}")
    name = data["name"]
    if name in names:
        raise SystemExit(f"duplicate agent name: {name}")
    names.add(name)

required = {"azure_infra", "db_query_specialist", "docs_maintainer", "code_reviewer", "security_reviewer"}
missing = required - names
if missing:
    raise SystemExit(f"missing required agents: {sorted(missing)}")
print(f"agents={len(agents)}")
PY
}

temp_install_check() {
	local tmp_home
	tmp_home="$(mktemp -d /tmp/codex-lattice-install-validation.XXXXXX)"
	TMP_ROOTS+=("$tmp_home")
	CODEX_HOME="$tmp_home" bash "$ROOT/install.sh" --ko >/tmp/codex-lattice-install-validation.log
	python3 - "$tmp_home" <<'PY'
import sys
from pathlib import Path
try:
    import tomllib
except Exception as exc:
    raise SystemExit(f"tomllib unavailable: {exc}")

home = Path(sys.argv[1])
data = tomllib.loads((home / "config.toml").read_text(encoding="utf-8"))
features = data.get("features", {})
for key in ("hooks", "multi_agent", "plugins", "goals", "image_generation"):
    if features.get(key) is not True:
        raise SystemExit(f"feature not enabled: {key}")
if "codex_hooks" in features:
    raise SystemExit("deprecated features.codex_hooks is present")
hooks = data.get("hooks", {})
hook_commands = sum(len(item.get("hooks", [])) for entries in hooks.values() for item in entries)
counts = {
    "skills_config": len(data.get("skills", {}).get("config", [])),
    "skill_dirs": len([p for p in (home / "skills").glob("*") if p.is_dir() and p.name != ".system"]),
    "agents": len(list((home / "agents").glob("*.toml"))),
    "hook_scripts": len(list((home / "hooks").glob("codex-*.sh"))),
    "scripts": len(list((home / "scripts").glob("*.sh"))),
    "hook_commands": hook_commands,
}
expected = {
    "skills_config": 47,
    "skill_dirs": 47,
    "agents": 15,
    "hook_scripts": 10,
    "scripts": 9,
    "hook_commands": 27,
}
for key, value in expected.items():
    if counts.get(key) != value:
        raise SystemExit(f"{key}: expected {value}, got {counts.get(key)}")
print(counts)
PY
}

runtime_hook_simulation_check() {
	local tmp hook_input error_input guard_input commit_input
	tmp="$(mktemp -d /tmp/codex-lattice-runtime-validation.XXXXXX)"
	TMP_ROOTS+=("$tmp")
	cd "$tmp"
	git init -q
	git config user.email test@example.com
	git config user.name "Codex Lattice Validation"
	mkdir -p src infra deploy db/queries docs/harness .codex-lattice/model-visible
	printf '# Runtime Validation App\n' >README.md
	printf '# AGENTS\n\nUse docs/harness for durable context.\n' >AGENTS.md
	printf '{"scripts":{"typecheck":"tsc --noEmit","test":"vitest run","build":"vite build"}}\n' >package.json
	printf 'export const oldValue = 1;\n' >src/api.ts
	printf '# Feature Spec\n' >docs/harness/FEATURE_SPEC.md
	printf 'AZURE_SECRET_TOKEN=should_not_appear_in_packets\n' >.env
	git add README.md AGENTS.md package.json src/api.ts docs/harness/FEATURE_SPEC.md
	git commit -q -m init

	printf 'export const getUser = () => ({ id: "1" });\n' >src/api.ts
	printf 'param location string = resourceGroup().location\n' >infra/main.bicep
	printf 'name: prd\nregion: koreacentral\n' >deploy/prd.yaml
	printf "select id, email from users where tenant_id = \$1 and id = \$2;\n" >db/queries/user_lookup.sql

	hook_input="$(
		jq -nc \
			--arg cwd "$tmp" \
			--arg session "runtime-validation" \
			--arg prompt "먼저 context packet 검증하고, 다음 hooks 로그 확인하고, 마지막 scheduler 운영 검증까지 해줘" \
			'{cwd:$cwd,session_id:$session,prompt:$prompt,tool_name:"exec_command",tool_input:{workdir:$cwd,cmd:"npm test"}}'
	)"
	error_input="$(
		jq -nc \
			--arg cwd "$tmp" \
			'{cwd:$cwd,session_id:"runtime-validation",hook_event_name:"PostToolUse",tool_name:"exec_command",tool_input:{workdir:$cwd,cmd:"npm test"},status:"error",exit_code:1,stderr:"Fatal Error: simulated validation failure"}'
	)"
	guard_input="$(
		jq -nc \
			--arg cwd "$tmp" \
			'{cwd:$cwd,tool_input:{workdir:$cwd,cmd:"git push --force origin main"}}'
	)"

	for event in SessionStart UserPromptSubmit PreToolUse PostToolUse PermissionRequest PreCompact PostCompact Stop; do
		printf '%s' "$hook_input" | "$ROOT/hooks/codex-event-log.sh" "$event"
	done
	printf '%s' "$hook_input" | "$ROOT/hooks/codex-git-strategy-log.sh"
	printf '%s' "$hook_input" | "$ROOT/hooks/codex-reflection-reminder.sh" UserPromptSubmit
	printf '%s' "$hook_input" | "$ROOT/scripts/codex-lattice-context-packet.sh" >/dev/null
	printf '%s' "$hook_input" | "$ROOT/hooks/codex-docs-sync-log.sh"
	jq -e '.required_docs | index("PRODUCTION_READINESS.md") and index("ENVIRONMENT_STRATEGY.md") and index("INFRA_SPEC.md") and index("QUERY_GUIDE.md") and index("DATA_MODEL.md")' .codex-lattice/docs-sync-queue.jsonl >/dev/null
	printf '%s' "$hook_input" | "$ROOT/hooks/codex-simplify-gate.sh" PermissionRequest >/dev/null
	printf '%s' "$error_input" | "$ROOT/hooks/codex-major-error-log.sh"
	printf '%s' "$hook_input" | "$ROOT/scripts/codex-lattice-harness-health.sh" >/dev/null
	printf '%s' "$hook_input" | "$ROOT/scripts/codex-lattice-review-packet.sh" >/dev/null

	rg -q 'infra/main.bicep' .codex-lattice/model-visible/CONTEXT_PACKET.md
	rg -q 'infra/main.bicep' .codex-lattice/model-visible/REVIEW_PACKET.md
	rg -q 'db/queries/user_lookup.sql' .codex-lattice/model-visible/REVIEW_PACKET.md
	rg -q 'risk level: `high`' .codex-lattice/model-visible/REVIEW_PACKET.md
	rg -q 'infra: `infra/main.bicep`' .codex-lattice/model-visible/REVIEW_PACKET.md
	rg -q 'data: `db/queries/user_lookup.sql`' .codex-lattice/model-visible/REVIEW_PACKET.md
	rg -q 'database_query: `db/queries/user_lookup.sql`' .codex-lattice/model-visible/REVIEW_PACKET.md
	rg -q 'security: `.env`' .codex-lattice/model-visible/REVIEW_PACKET.md
	if awk '/## Changed Files/{flag=1; next} /## Risk Routing/{flag=0} flag && /^- `\.codex-lattice/ {found=1} END {exit found ? 0 : 1}' .codex-lattice/model-visible/REVIEW_PACKET.md; then
		printf "runtime files leaked into changed-file routing\n" >&2
		return 1
	fi
	if grep -R "should_not_appear_in_packets" .codex-lattice/model-visible .codex-lattice/runs >/dev/null; then
		printf "secret value leaked into packet files\n" >&2
		return 1
	fi
	test -f .codex-lattice/runs/runtime-validation/context-packet.md
	test -f .codex-lattice/runs/runtime-validation/review-packet.md
	test -f .codex-lattice/model-visible/REFLECTION_REQUIRED.md
	test -f .codex-lattice/model-visible/DOCS_AGENT_REQUIRED.md
	test -f .codex-lattice/model-visible/SIMPLIFY_REQUIRED.md
	test -f .codex-lattice/model-visible/MAJOR_ERRORS.md
	jq -e 'select(.codex.features.hooks == true) | select(.codex.hook_commands == 27)' .codex-lattice/harness-health-latest.json >/dev/null
	python3 - <<'PY'
import json
from pathlib import Path
lines = Path(".codex-lattice/logs/events.jsonl").read_text(encoding="utf-8").splitlines()
events = [json.loads(line) for line in lines if line.strip()]
required = {"SessionStart", "UserPromptSubmit", "PreToolUse", "PostToolUse", "PermissionRequest", "PreCompact", "PostCompact", "Stop"}
seen = {event.get("event") for event in events}
missing = required - seen
if missing:
    raise SystemExit(f"missing logged events: {sorted(missing)}")
print(f"events={len(events)}")
PY

	set +e
	printf '%s' "$guard_input" | "$ROOT/hooks/codex-git-guard.sh" >/tmp/codex-lattice-guard.out 2>/tmp/codex-lattice-guard.err
	local guard_code=$?
	set -e
	if [ "$guard_code" -ne 2 ]; then
		printf "git guard expected exit 2, got %s\n" "$guard_code" >&2
		cat /tmp/codex-lattice-guard.err >&2
		return 1
	fi

	git switch -q -c feature/runtime-validation
	git add src/api.ts infra/main.bicep docs/harness/FEATURE_SPEC.md
	git commit -q -m "feat: runtime validation"
	commit_input="$(
		jq -nc \
			--arg cwd "$tmp" \
			'{cwd:$cwd,tool_input:{workdir:$cwd,cmd:"git commit -m runtime-validation"}}'
	)"
	printf '%s' "$commit_input" | "$ROOT/hooks/codex-commit-log.sh"
	ls .codex-lattice/commits/*.json .codex-lattice/commits/*.md >/dev/null

	"$ROOT/scripts/codex-lattice-log-analyze.sh" "$tmp/.codex-lattice/reports" "$tmp/.codex-lattice/logs/events.jsonl" >/dev/null
	jq -e '.total_events >= 8 and .failure_count == 0' "$tmp/.codex-lattice/reports/log-analysis-latest.json" >/dev/null
	printf "tmp=%s\n" "$tmp"
}

scheduler_check() {
	CODEX_LATTICE_USE_CODEX=0 "$ROOT/scripts/codex-lattice-scheduler.sh" run >/tmp/codex-lattice-scheduler-run.out
	test -f "$ROOT/.codex-lattice/reports/health-latest.json"
	test -f "$ROOT/.codex-lattice/reports/log-analysis-latest.json"
	test -f "$ROOT/.codex-lattice/reports/scheduled-report-latest.md"
	jq -e '.checks | length >= 3' "$ROOT/.codex-lattice/reports/health-latest.json" >/dev/null

	if command -v launchctl >/dev/null 2>&1; then
		local label="com.codex-lattice.validation.$$"
		CODEX_LATTICE_LAUNCHD_LABEL="$label" CODEX_LATTICE_USE_CODEX=0 CODEX_LATTICE_INTERVAL_SECONDS=86400 "$ROOT/scripts/codex-lattice-scheduler.sh" enable >/tmp/codex-lattice-scheduler-enable.out
		CODEX_LATTICE_LAUNCHD_LABEL="$label" "$ROOT/scripts/codex-lattice-scheduler.sh" status >/tmp/codex-lattice-scheduler-status.out
		rg -q "$label" /tmp/codex-lattice-scheduler-status.out
		CODEX_LATTICE_LAUNCHD_LABEL="$label" "$ROOT/scripts/codex-lattice-scheduler.sh" disable >/tmp/codex-lattice-scheduler-disable.out
		if [ -f "$HOME/Library/LaunchAgents/$label.plist" ] || launchctl list 2>/dev/null | rg -q "$label"; then
			printf "validation launchd label still active after disable\n" >&2
			return 1
		fi
	fi
}

run_check "bash syntax" bash -c "cd '$ROOT' && bash -n install.sh && for f in hooks/codex-*.sh scripts/*.sh; do bash -n \"\$f\"; done"
run_check "shellcheck" bash -c "cd '$ROOT' && shellcheck install.sh hooks/codex-*.sh scripts/*.sh"
run_check "shfmt" bash -c "cd '$ROOT' && shfmt -d install.sh hooks/codex-*.sh scripts/*.sh"
run_check "json metadata" bash -c "cd '$ROOT' && jq empty .codex-plugin/plugin.json .agents/plugins/marketplace.json .mcp.json hooks/hooks.json"
run_check "hook registry" hook_registry_check
run_check "skill validation" skill_validation_check
run_check "agent toml" agent_toml_check
run_check "integration checker" bash -c "cd '$ROOT' && bash scripts/check-codex-integrations.sh"
run_check "temp install" temp_install_check
run_check "runtime hook simulation" runtime_hook_simulation_check
run_check "scheduler operations" scheduler_check
run_check "whitespace diff" bash -c "cd '$ROOT' && git diff --check"
run_check "secret scan" bash -c "cd '$ROOT' && gitleaks detect --no-banner --redact --source ."

jq -s \
	--arg ts "$TS" \
	--arg root "$ROOT" \
	--arg codex_home "$CODEX_HOME" \
	'{ts:$ts,root:$root,codex_home:$codex_home,checks:.,summary:{total:length,failures:map(select(.status=="fail"))|length}}' \
	"$CHECKS_FILE" >"$REPORT_JSON"

{
	printf "# Codex Lattice Runtime Validation\n\n"
	printf -- "- generated: %s\n" "$TS"
	printf -- "- root: %s\n" "$ROOT"
	printf -- "- codex home: %s\n\n" "$CODEX_HOME"
	printf "## Checks\n\n"
	jq -r '.checks[] | "- \(.status | ascii_upcase): \(.name) (exit \(.exit_code))"' "$REPORT_JSON"
	printf "\n## Summary\n\n"
	jq -r '"- total: \(.summary.total)\n- failures: \(.summary.failures)"' "$REPORT_JSON"
} >"$REPORT_MD"

printf "%s\n" "$REPORT_MD"
exit "$FAILURES"
