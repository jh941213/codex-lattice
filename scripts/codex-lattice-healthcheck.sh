#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
OUT_DIR="${1:-$ROOT/.codex-lattice/reports}"
mkdir -p "$OUT_DIR"

TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
JSON_OUT="$OUT_DIR/health-latest.json"
MD_OUT="$OUT_DIR/health-latest.md"

status_for() {
	local code="$1"
	if [ "$code" -eq 0 ]; then
		printf "pass"
	else
		printf "fail"
	fi
}

run_check() {
	local name="$1"
	shift
	local output code
	set +e
	output="$("$@" 2>&1)"
	code=$?
	set -e
	printf '{"name":%s,"status":%s,"exit_code":%s,"output":%s}\n' \
		"$(jq -Rn --arg v "$name" '$v')" \
		"$(jq -Rn --arg v "$(status_for "$code")" '$v')" \
		"$code" \
		"$(jq -Rn --arg v "${output:0:4000}" '$v')"
}

skill_dirs="$(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
agent_files="$(find "$ROOT/.codex/agents" -maxdepth 1 -name '*.toml' | wc -l | tr -d ' ')"
hook_scripts="$(find "$ROOT/hooks" -maxdepth 1 -name 'codex-*.sh' | wc -l | tr -d ' ')"

local_summary="$(
	python3 - "$CODEX_HOME" <<'PY'
import json
import sys
from pathlib import Path
try:
    import tomllib
except Exception:
    print(json.dumps({"error": "tomllib unavailable"}))
    raise SystemExit(0)

home = Path(sys.argv[1]).expanduser()
config_path = home / "config.toml"
data = {}
if config_path.exists():
    try:
        data = tomllib.loads(config_path.read_text(encoding="utf-8"))
    except Exception as exc:
        print(json.dumps({"error": str(exc)}))
        raise SystemExit(0)

features = data.get("features", {})
hooks = data.get("hooks", {})
summary = {
    "config_exists": config_path.exists(),
    "features": {key: features.get(key) for key in ["hooks", "multi_agent", "plugins", "goals", "image_generation"]},
    "skills_config": len(data.get("skills", {}).get("config", [])),
    "agents": len(list((home / "agents").glob("*.toml"))) if (home / "agents").exists() else 0,
    "hook_scripts": len(list((home / "hooks").glob("codex-*.sh"))) if (home / "hooks").exists() else 0,
    "hook_commands": sum(len(item.get("hooks", [])) for entries in hooks.values() for item in entries) if isinstance(hooks, dict) else 0,
}
print(json.dumps(summary, sort_keys=True))
PY
)"

checks_file="$(mktemp)"
{
	run_check "bash syntax" bash -c "cd '$ROOT' && bash -n install.sh && for f in hooks/codex-*.sh scripts/*.sh; do bash -n \"\$f\"; done"
	run_check "json metadata" bash -c "cd '$ROOT' && jq empty .codex-plugin/plugin.json .agents/plugins/marketplace.json .mcp.json hooks/hooks.json"
	run_check "skill yaml" bash -c "cd '$ROOT' && ruby -ryaml -e 'Dir[\"skills/*/SKILL.md\"].each { |f| text=File.read(f); m=text.match(/\\A---\\n(.*?)\\n---\\n/m) or abort(\"missing frontmatter: #{f}\"); data=YAML.safe_load(m[1], permitted_classes: [], aliases: false); abort(\"missing name: #{f}\") unless data[\"name\"]; abort(\"missing description: #{f}\") unless data[\"description\"] }'"
	run_check "integration checker" bash -c "cd '$ROOT' && bash scripts/check-codex-integrations.sh"
	if command -v shellcheck >/dev/null 2>&1; then
		run_check "shellcheck" bash -c "cd '$ROOT' && shellcheck install.sh hooks/codex-*.sh scripts/*.sh"
	fi
	if command -v shfmt >/dev/null 2>&1; then
		run_check "shfmt" bash -c "cd '$ROOT' && shfmt -d install.sh hooks/codex-*.sh scripts/*.sh"
	fi
	if command -v gitleaks >/dev/null 2>&1; then
		run_check "gitleaks" bash -c "cd '$ROOT' && gitleaks detect --no-banner --redact --source ."
	fi
} >"$checks_file"

jq -s \
	--arg ts "$TS" \
	--arg root "$ROOT" \
	--argjson local "$local_summary" \
	--argjson skill_dirs "$skill_dirs" \
	--argjson agent_files "$agent_files" \
	--argjson hook_scripts "$hook_scripts" \
	'{
	  ts: $ts,
	  root: $root,
	  repo: {skill_dirs: $skill_dirs, agent_files: $agent_files, hook_scripts: $hook_scripts},
	  local_codex: $local,
	  checks: .
	}' "$checks_file" >"$JSON_OUT"

{
	fence='```'
	printf "# Codex Lattice Healthcheck\n\n"
	printf -- "- generated: %s\n" "$TS"
	printf -- "- root: %s\n" "$ROOT"
	printf -- "- repo skills: %s\n" "$skill_dirs"
	printf -- "- repo agents: %s\n" "$agent_files"
	printf -- "- repo hook scripts: %s\n\n" "$hook_scripts"
	printf "## Local Codex\n\n"
	printf "%sjson\n" "$fence"
	jq -S . <<<"$local_summary"
	printf "%s\n\n" "$fence"
	printf "## Checks\n\n"
	jq -r '.checks[] | "- \(.status | ascii_upcase): \(.name) (exit \(.exit_code))"' "$JSON_OUT"
} >"$MD_OUT"

rm -f "$checks_file"
printf "%s\n" "$MD_OUT"
