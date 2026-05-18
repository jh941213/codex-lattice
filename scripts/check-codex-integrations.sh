#!/usr/bin/env bash
set -u

missing_required_brew=()
missing_recommended_brew=()
missing_recommended_npm=()
missing_optional_env=()

check_required_brew() {
	local command_name="$1"
	local package_name="$2"
	local purpose="$3"
	if command -v "$command_name" >/dev/null 2>&1; then
		printf "ok|required|%s|%s\n" "$command_name" "$purpose"
	else
		printf "missing|required|%s|%s\n" "$command_name" "$purpose"
		missing_required_brew+=("$package_name")
	fi
}

check_recommended_brew() {
	local command_name="$1"
	local package_name="$2"
	local purpose="$3"
	if command -v "$command_name" >/dev/null 2>&1; then
		printf "ok|recommended|%s|%s\n" "$command_name" "$purpose"
	else
		printf "missing|recommended|%s|%s\n" "$command_name" "$purpose"
		missing_recommended_brew+=("$package_name")
	fi
}

check_recommended_npm() {
	local command_name="$1"
	local package_name="$2"
	local purpose="$3"
	if command -v "$command_name" >/dev/null 2>&1; then
		printf "ok|recommended|%s|%s\n" "$command_name" "$purpose"
	else
		printf "missing|recommended|%s|%s\n" "$command_name" "$purpose"
		missing_recommended_npm+=("$package_name")
	fi
}

check_recommended_any_brew() {
	local display_name="$1"
	local package_name="$2"
	local purpose="$3"
	shift 3
	local command_name
	for command_name in "$@"; do
		if command -v "$command_name" >/dev/null 2>&1; then
			printf "ok|recommended|%s|%s via %s\n" "$display_name" "$purpose" "$command_name"
			return
		fi
	done
	printf "missing|recommended|%s|%s\n" "$display_name" "$purpose"
	missing_recommended_brew+=("$package_name")
}

check_optional_secret() {
	local display_name="$1"
	local env_name="$2"
	local jq_filter="$3"
	local purpose="$4"
	if [ -n "${!env_name:-}" ]; then
		printf "ok|optional|%s|%s via env:%s\n" "$display_name" "$purpose" "$env_name"
		return
	fi
	if [ -f "$HOME/.mcp.json" ] && command -v jq >/dev/null 2>&1 && jq -e "$jq_filter | strings | length > 0" "$HOME/.mcp.json" >/dev/null 2>&1; then
		printf "ok|optional|%s|%s via ~/.mcp.json\n" "$display_name" "$purpose"
		return
	fi
	printf "missing|optional|%s|%s\n" "$display_name" "$purpose"
	missing_optional_env+=("$env_name")
}

unique_join() {
	printf "%s\n" "$@" | awk 'NF && !seen[$0]++' | tr '\n' ' ' | sed 's/[[:space:]]*$//'
}

check_required_brew git git "version control"
check_required_brew rg ripgrep "fast repository search"
check_required_brew jq jq "JSON parsing in hooks and scripts"
check_required_brew sg ast-grep "AST-aware code pattern matching"
check_required_brew difft difftastic "structural diffs for review"
check_required_brew gitleaks gitleaks "secret scanning"
check_required_brew scc scc "code statistics and complexity"
check_required_brew shellcheck shellcheck "shell script linting"
check_required_brew shfmt shfmt "shell script formatting"

check_recommended_brew fd fd "fast file discovery"
check_recommended_brew yq yq "YAML/TOML-ish config inspection"
check_recommended_brew gh gh "GitHub PR and issue workflow"
check_recommended_brew delta git-delta "readable git diff paging"
check_recommended_brew osv-scanner osv-scanner "dependency vulnerability scanning"
check_recommended_brew uv uv "Python project and tool runner"
check_recommended_brew ruff ruff "Python lint and format"
check_recommended_brew pnpm pnpm "fast Node package manager"
check_recommended_brew az azure-cli "Azure resource inspection, cost review, and operations"
if command -v launchctl >/dev/null 2>&1; then
	printf "ok|optional|launchctl|macOS scheduler control for optional scheduled operations\n"
else
	printf "missing|optional|launchctl|macOS-only scheduler control; use cron/systemd examples on non-macOS\n"
fi
check_recommended_any_brew "semgrep|sgrep" semgrep "semantic static analysis and security rules" semgrep sgrep
check_recommended_npm mgrep @mixedbread/mgrep "semantic local search and Codex MCP integration"
check_optional_secret tavily TAVILY_API_KEY '.mcpServers.tavily.env.TAVILY_API_KEY // empty' "Tavily web search MCP"
check_optional_secret exa EXA_API_KEY '.mcpServers.exa.env.EXA_API_KEY // empty' "Exa web/search research MCP"

if command -v npx >/dev/null 2>&1; then
	printf "ok|on-demand|npx|madge, knip, jscpd, playwright can run through npx\n"
else
	printf "missing|on-demand|npx|install Node.js/npm for madge, knip, jscpd, playwright\n"
	missing_recommended_brew+=("node")
fi

if ((${#missing_required_brew[@]})); then
	printf "\nrequired install:\n"
	printf "brew install %s\n" "$(unique_join "${missing_required_brew[@]}")"
fi

if ((${#missing_recommended_brew[@]})); then
	printf "\nrecommended Homebrew install:\n"
	printf "brew install %s\n" "$(unique_join "${missing_recommended_brew[@]}")"
fi

if ((${#missing_recommended_npm[@]})); then
	printf "\nrecommended npm install:\n"
	printf "npm install -g %s\n" "$(unique_join "${missing_recommended_npm[@]}")"
fi

if ((${#missing_optional_env[@]})); then
	printf "\noptional search MCP keys:\n"
	for env_name in $(unique_join "${missing_optional_env[@]}"); do
		printf "export %s=...\n" "$env_name"
	done
	printf "or add Tavily/Exa credentials to ~/.mcp.json\n"
fi

if ((${#missing_required_brew[@]})); then
	exit 1
fi
