#!/usr/bin/env bash

# Codex Lattice Installer
# https://github.com/jh941213/codex-lattice

set -euo pipefail

case "${1:-}" in
--en | --english | --ko | --korean | "") ;;
*)
	echo "Usage: bash install.sh [--ko|--en]"
	exit 2
	;;
esac

echo "Codex Lattice 설치 시작..."

TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

if [ -d ".git" ] && [ -f ".codex-plugin/plugin.json" ]; then
	SRC_DIR="$(pwd)"
else
	git clone --depth 1 https://github.com/jh941213/codex-lattice.git "$TEMP_DIR"
	SRC_DIR="$TEMP_DIR"
fi

CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
mkdir -p "$CODEX_HOME/skills" "$CODEX_HOME/hooks" "$CODEX_HOME/agents" "$CODEX_HOME/scripts" "$CODEX_HOME/rules"

echo "Copying Codex skills, hooks, rules, and sub-agent config..."

if [ -d "$SRC_DIR/skills" ]; then
	cp -R "$SRC_DIR/skills/"* "$CODEX_HOME/skills/" 2>/dev/null || true
fi

if [ -d "$SRC_DIR/hooks" ]; then
	cp "$SRC_DIR/hooks/"codex-*.sh "$CODEX_HOME/hooks/" 2>/dev/null || true
	chmod +x "$CODEX_HOME/hooks/"codex-*.sh 2>/dev/null || true
fi

if [ -d "$SRC_DIR/scripts" ]; then
	cp "$SRC_DIR/scripts/check-codex-integrations.sh" "$CODEX_HOME/scripts/" 2>/dev/null || true
	chmod +x "$CODEX_HOME/scripts/check-codex-integrations.sh" 2>/dev/null || true
fi

if [ -d "$SRC_DIR/rules" ]; then
	cp "$SRC_DIR/rules/"*.md "$CODEX_HOME/rules/" 2>/dev/null || true
fi

if [ -d "$SRC_DIR/.codex/agents" ]; then
	cp "$SRC_DIR/.codex/agents/"*.toml "$CODEX_HOME/agents/" 2>/dev/null || true
fi

mkdir -p "$CODEX_HOME/harness/model-visible" "$CODEX_HOME/harness/logs" "$CODEX_HOME/harness/commits"
if [ -f "$SRC_DIR/Brewfile.codex" ]; then
	cp "$SRC_DIR/Brewfile.codex" "$CODEX_HOME/harness/Brewfile.codex" 2>/dev/null || true
fi
if [ -f "$SRC_DIR/.codex-lattice/model-visible/MAJOR_ERRORS.md" ] && [ ! -f "$CODEX_HOME/harness/model-visible/MAJOR_ERRORS.md" ]; then
	cp "$SRC_DIR/.codex-lattice/model-visible/MAJOR_ERRORS.md" "$CODEX_HOME/harness/model-visible/MAJOR_ERRORS.md"
fi
if [ -f "$SRC_DIR/.codex-lattice/model-visible/AZURE_INFRA_MEMORY.md" ] && [ ! -f "$CODEX_HOME/harness/model-visible/AZURE_INFRA_MEMORY.md" ]; then
	cp "$SRC_DIR/.codex-lattice/model-visible/AZURE_INFRA_MEMORY.md" "$CODEX_HOME/harness/model-visible/AZURE_INFRA_MEMORY.md"
fi

CONFIG_FILE="$CODEX_HOME/config.toml"
touch "$CONFIG_FILE"

python3 - "$CONFIG_FILE" "$CODEX_HOME" "$SRC_DIR" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1]).expanduser()
codex_home = Path(sys.argv[2]).expanduser()
src_dir = Path(sys.argv[3]).expanduser()
text = path.read_text(encoding="utf-8") if path.exists() else ""
start = "# >>> codex-lattice >>>"
end = "# <<< codex-lattice <<<"
legacy_name = "my-" + "codex-" + "harness"
managed_markers = [
    (start, end),
    (f"# >>> {legacy_name} >>>", f"# <<< {legacy_name} <<<"),
]

skill_root = src_dir / "skills"
skill_names = []
if skill_root.exists():
    skill_names = sorted(
        p.name for p in skill_root.iterdir()
        if p.is_dir() and (p / "SKILL.md").exists()
    )
skill_entries = "\n".join(
    f'[[skills.config]]\npath = "./skills/{name}"\nenabled = true\n'
    for name in skill_names
)

block = "# >>> codex-lattice >>>\n" + skill_entries + """
[mcp_servers.tavily]
command = "bash"
args = ["-lc", "TAVILY_API_KEY=\\"${TAVILY_API_KEY:-$(jq -r '.mcpServers.tavily.env.TAVILY_API_KEY // empty' ~/.mcp.json 2>/dev/null)}\\"; export TAVILY_API_KEY; exec npx -y tavily-mcp"]

[mcp_servers.exa]
command = "bash"
args = ["-lc", "EXA_API_KEY=\\"${EXA_API_KEY:-$(jq -r '.mcpServers.exa.env.EXA_API_KEY // empty' ~/.mcp.json 2>/dev/null)}\\"; export EXA_API_KEY; exec npx -y exa-mcp-server"]

[[hooks.SessionStart]]
matcher = "*"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-event-log.sh SessionStart", timeout = 5 },
  { type = "command", command = "bash ~/.codex/hooks/codex-visible-error-reminder.sh", timeout = 5 },
]

[[hooks.UserPromptSubmit]]
matcher = "*"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-event-log.sh UserPromptSubmit", timeout = 5 },
  { type = "command", command = "bash ~/.codex/hooks/codex-git-strategy-log.sh", timeout = 5 },
]

[[hooks.PreToolUse]]
matcher = "*"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-event-log.sh PreToolUse", timeout = 5 },
]

[[hooks.PreToolUse]]
matcher = "exec_command"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-git-guard.sh", timeout = 5 },
]

[[hooks.PostToolUse]]
matcher = "*"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-event-log.sh PostToolUse", timeout = 5 },
  { type = "command", command = "bash ~/.codex/hooks/codex-major-error-log.sh", timeout = 5 },
  { type = "command", command = "bash ~/.codex/hooks/codex-docs-sync-log.sh", timeout = 5 },
  { type = "command", command = "bash ~/.codex/hooks/codex-simplify-gate.sh PostToolUse", timeout = 5 },
]

[[hooks.PostToolUse]]
matcher = "exec_command"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-commit-log.sh", timeout = 5 },
]

[[hooks.PermissionRequest]]
matcher = "*"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-event-log.sh PermissionRequest", timeout = 5 },
  { type = "command", command = "bash ~/.codex/hooks/codex-simplify-gate.sh PermissionRequest", timeout = 5 },
]

[[hooks.PreCompact]]
matcher = "*"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-event-log.sh PreCompact", timeout = 5 },
]

[[hooks.PostCompact]]
matcher = "*"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-event-log.sh PostCompact", timeout = 5 },
  { type = "command", command = "bash ~/.codex/hooks/codex-visible-error-reminder.sh", timeout = 5 },
]

[[hooks.Stop]]
matcher = "*"
hooks = [
  { type = "command", command = "bash ~/.codex/hooks/codex-event-log.sh Stop", timeout = 5 },
  { type = "command", command = "bash ~/.codex/hooks/codex-simplify-gate.sh Stop", timeout = 5 },
]
# <<< codex-lattice <<<
"""

def strip_managed_block(value: str) -> str:
    for block_start, block_end in managed_markers:
        while block_start in value and block_end in value:
            before = value.split(block_start, 1)[0].rstrip()
            after = value.split(block_end, 1)[1].lstrip()
            value = (before + "\n\n" if before else "") + after
    return value

def ensure_table(value: str, table: str, assignments: dict[str, str]) -> str:
    lines = value.splitlines()
    header = f"[{table}]"
    for i, line in enumerate(lines):
        if line.strip() == header:
            j = i + 1
            while j < len(lines) and not lines[j].lstrip().startswith("["):
                j += 1
            section = lines[i + 1:j]
            existing = {s.split("=", 1)[0].strip() for s in section if "=" in s and not s.lstrip().startswith("#")}
            inserts = [f"{k} = {v}" for k, v in assignments.items() if k not in existing]
            lines[j:j] = inserts
            return "\n".join(lines) + ("\n" if value.endswith("\n") else "")
    addition = "\n".join([header] + [f"{k} = {v}" for k, v in assignments.items()])
    return value.rstrip() + ("\n\n" if value.strip() else "") + addition + "\n"

def remove_table_keys(value: str, table: str, keys: set[str]) -> str:
    lines = value.splitlines()
    header = f"[{table}]"
    out = []
    in_table = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("[") and stripped.endswith("]"):
            in_table = stripped == header
            out.append(line)
            continue
        if in_table and "=" in line and line.split("=", 1)[0].strip() in keys:
            continue
        out.append(line)
    return "\n".join(out) + ("\n" if value.endswith("\n") else "")

def ensure_agent(value: str, name: str, description: str, config_file: str, nicknames: list[str]) -> str:
    header = f"[agents.{name}]"
    value = remove_table(value, header)
    nick = "[" + ", ".join(f'"{n}"' for n in nicknames) + "]"
    block = (
        f"{header}\n"
        f'description = "{description}"\n'
        f'config_file = "{config_file}"\n'
        f"nickname_candidates = {nick}\n"
    )
    return value.rstrip() + "\n\n" + block

def remove_table(value: str, header: str) -> str:
    lines = value.splitlines()
    out = []
    i = 0
    while i < len(lines):
        if lines[i].strip() == header:
            i += 1
            while i < len(lines) and not lines[i].lstrip().startswith("["):
                i += 1
            continue
        out.append(lines[i])
        i += 1
    return "\n".join(out) + ("\n" if value.endswith("\n") else "")

text = strip_managed_block(text)
text = remove_table_keys(text, "features", {"codex_hooks", "hooks"})
text = remove_table(text, "[mcp_servers.tavily]")
text = remove_table(text, "[mcp_servers.exa]")
text = ensure_table(text, "features", {"hooks": "true", "multi_agent": "true", "plugins": "true", "goals": "true", "image_generation": "true"})
text = ensure_table(text, "agents", {"max_threads": "6", "max_depth": "1", "job_max_runtime_seconds": "1800"})

agents = [
    ("planner", "복잡한 기능 구현이나 리팩토링을 위한 전문 계획 수립 에이전트.", "./agents/planner.toml", ["planner", "plan-reviewer"]),
    ("architect", "아키텍처, 모듈 경계, 의존성 방향을 검토하는 설계 에이전트.", "./agents/architect.toml", ["architect", "architecture-reviewer"]),
    ("frontend_developer", "프론트엔드 UI, React, 접근성, UX 구현을 담당하는 에이전트.", "./agents/frontend-developer.toml", ["frontend", "ui-builder"]),
    ("junior_mentor", "초보 개발자가 구현 내용을 이해하도록 쉬운 설명과 학습 문서를 만드는 멘토 에이전트.", "./agents/junior-mentor.toml", ["junior", "mentor", "junior-mentor"]),
    ("prd_planner", "제품 아이디어를 CPS, PRD, SPEC, 리스크, 기능 문서로 합성하는 기획 에이전트.", "./agents/prd-planner.toml", ["prd", "prd-planner", "product-planner"]),
    ("code_reviewer", "변경사항의 버그, 회귀, 보안 위험, 테스트 누락을 찾는 코드 리뷰 에이전트.", "./agents/code-reviewer.toml", ["reviewer", "code-reviewer"]),
    ("security_reviewer", "보안, 비밀정보, 입력 검증, 의존성 위험을 검토하는 에이전트.", "./agents/security-reviewer.toml", ["security", "security-reviewer"]),
    ("azure_infra", "Azure CLI 기반 인프라 산정, 리소스 검토, 운영, 모니터링을 담당하는 에이전트.", "./agents/azure-infra.toml", ["azure", "azure-infra", "azops", "cloudops"]),
    ("qa", "검증, 테스트 시나리오, 사용자 관점 품질 게이트를 담당하는 QA 에이전트.", "./agents/qa.toml", ["qa", "quality-reviewer"]),
    ("evaluator", "작업 결과를 독립적으로 평가하고 개선 루프를 제안하는 에이전트.", "./agents/evaluator.toml", ["evaluator", "quality-evaluator"]),
    ("docs_writer", "변경사항에 맞춰 문서와 인계 내용을 정리하는 에이전트.", "./agents/docs-writer.toml", ["docs", "docs-writer"]),
    ("docs_maintainer", "코딩 작업 중 생성된 docs/harness 문서를 최신 구현과 동기화하는 에이전트.", "./agents/docs-maintainer.toml", ["docs-maintainer", "doc-sync"]),
    ("tdd_guide", "테스트 우선 개발과 테스트 설계를 돕는 에이전트.", "./agents/tdd-guide.toml", ["tdd", "test-guide"]),
    ("stitch_developer", "Stitch 산출물을 React 컴포넌트와 디자인 토큰으로 옮기는 에이전트.", "./agents/stitch-developer.toml", ["stitch", "stitch-dev"]),
]
for agent in agents:
    text = ensure_agent(text, *agent)

text = text.rstrip() + "\n\n" + block + "\n"

path.write_text(text, encoding="utf-8")
PY

echo "설치 완료. config 변경을 로드하려면 Codex를 재시작하세요."
echo "설치 항목: skills, hooks, rules, sub-agent config, config.toml 관리 블록."
