<div align="center">

**🌐 [English](README_EN.md) | 한국어**



# Codex Lattice

**엔터프라이즈 운영 환경에서 실제로 쓰기 위한 Codex agent harness**

[![Version](https://img.shields.io/badge/version-0.0.1-7C3AED.svg?style=for-the-badge)](https://github.com/jh941213/codex-lattice)
[![License](https://img.shields.io/badge/license-MIT-E87C3E.svg?style=for-the-badge)](LICENSE)
[![Skills](https://img.shields.io/badge/skills-47-blue.svg?style=for-the-badge)](#skills-47개)
[![Agents](https://img.shields.io/badge/agents-15-green.svg?style=for-the-badge)](#custom-agents-15개)
[![Hooks](https://img.shields.io/badge/hooks-27-111827.svg?style=for-the-badge)](#항상-켜지는-hooks)

`Skills` · `Custom Agents` · `Hooks` · `Git Strategy` · `Docs Sync` · `Observability` · `Scheduler`

<img src="assets/codex-lattice-hero.png" alt="Codex Lattice hero illustration" width="880" />

</div>

---

## 무엇인가요

Codex Lattice는 OpenAI Codex를 실무 개발에 맞게 세팅하는 설치형 하네스입니다.

데모용 프롬프트 묶음이 아니라, 리플렉션, 운영 관측성, 검증 증거, 문서 동기화, 리뷰 경계, 스케줄링을 하나의 반복 가능한 작업 루프로 묶어 **엔터프라이즈 개발/운영 환경에서 실제로 쓸 수 있게 만드는 것**을 목표로 합니다.

설치하면 Codex에 **47개 skills**, **15개 custom agents**, **27개 lifecycle hook commands**, 작업 로그, 커밋 로그, 모델이 읽는 주요 에러 로그, Azure Infra memory, docs 자동 동기화 규칙이 들어갑니다.

| 영역 | 제공하는 것 |
|------|-------------|
| 작업 루프 | 계획, Git 전략, 구현, 검증, 문서 갱신, 커밋 후보 기록 |
| 리플렉션 | 최신 사용자 지시 재확인, compact resume, 방향 이탈 점검, lesson learned 기록 |
| 항상 켜지는 Hooks | 이벤트 로그, 주요 에러 로그, docs sync gate, simplify/reflection gate |
| Skills & Agents | PRD, SPEC, 리뷰, 검증, 보안, 운영, Azure, UI, 테스트 특화 작업자 |
| 운영 문서 | 기능 명세, API, 인프라, production/prd, 환경 전략, 쿼리, 보안, 데이터, 테스트, SLO, runbook 문서 |
| 운영 관측성 | health packet, log analysis, scheduler report, 주요 에러 model-visible memory |
| 리뷰 증거 | context packet, review packet, harness health, validation evidence |
| 검색/분석 | `rg`, `sg`, `mgrep`, Tavily, Exa, Semgrep, Gitleaks, Difftastic |
| 스케줄러 | 꺼짐 기본값의 healthcheck/log analysis. 필요할 때만 `enable` |

Codex가 따르게 되는 기본 루프는 단순합니다.

```text
계획 세우기 -> Git 전략 남기기 -> 구현 -> 로그 기록 -> 검증 -> docs/harness 갱신 -> 커밋 후보 기록
```

## 왜 만들었나요

엔터프라이즈 환경에서는 “코드가 돌아간다”만으로 충분하지 않습니다. Codex가 최신 지시를 잃지 않았는지, 어떤 근거로 컨텍스트를 읽었는지, 검증을 실제로 했는지, 운영/보안/데이터/릴리즈 문서가 따라왔는지, 장애와 반복 실패를 다음 실행이 다시 볼 수 있는지까지 남아야 합니다.

Codex Lattice는 그 요구를 README가 아니라 하네스 동작으로 강제합니다. hook은 작업 흐름을 기록하고, packet은 모델이 봐야 할 요약을 만들고, docs gate는 산출물을 밀어 올리며, reflection gate는 순차 지시나 compact 이후 방향을 다시 잡게 합니다.

## 3분 설치

macOS와 Homebrew 기준입니다. 민감한 API 키는 repo에 저장하지 않고 환경변수나 기존 `~/.mcp.json`에서 읽습니다.

```bash
git clone https://github.com/jh941213/codex-lattice.git
cd codex-lattice

# 1. 코드 검색, 구조적 diff, 시크릿 스캔, shell 검증 도구 설치
brew bundle --file Brewfile.codex

# 2. mgrep semantic search 연동
npm install -g @mixedbread/mgrep

# 3. 선택: Tavily/Exa 검색 MCP 키
export TAVILY_API_KEY="<your tavily key>"
export EXA_API_KEY="<your exa key>"

# 4. 한국어 하네스 설치
bash install.sh --ko
```

설치 후 **Codex를 재시작**하세요. 처음 한 번은 `/hooks`에서 새 hook을 검토하고 trust 해야 합니다.

```text
/hooks
```

`27 hooks need review before they can run`은 첫 설치 후 정상 동작입니다. trust가 끝나면 `/hooks` 화면에서 `Installed`와 `Active` 숫자가 같아집니다.

## 첫 확인

설치가 끝나면 아래 3가지를 빠르게 확인합니다.

```bash
# 설치된 CLI/MCP/검증 도구 확인
~/.codex/scripts/check-codex-integrations.sh

# 현재 repo 기준으로 하네스 검증
bash scripts/check-codex-integrations.sh

# scheduler는 기본 OFF인지 확인
./scripts/codex-lattice-scheduler.sh status
```

하네스 자체를 깊게 검증하려면 runtime validation을 실행합니다. 작은 단위의 shell/JSON/skill 검증부터 temp install, hook trigger simulation, packet 생성, event log 적재, git guard, commit log, scheduler run/enable/disable, secret scan까지 한 번에 확인합니다.

```bash
./scripts/validate-codex-lattice-runtime.sh
```

Codex 안에서는 다음 순서로 보면 됩니다.

```text
/debug-config
/hooks
/status
```

## 사전 요구사항

| 구분 | 설치 항목 | 확인 방법 |
|------|-----------|-----------|
| 필수 | Git | `git --version` |
| 필수 | Python 3.11+ 권장 | `python3 --version` |
| 필수 | OpenAI Codex CLI | `codex --version` |
| 권장 | Homebrew | `brew --version` |
| 권장 | GitHub CLI | `gh --version` |
| 권장 | Node.js/npm | `node --version`, `npm --version` |

통합 도구는 `Brewfile.codex`로 한 번에 설치합니다. 도구가 없으면 해당 검사는 skip 되지만, 팀 공용 하네스로 쓰려면 전체 설치를 권장합니다.

| 도구 | 용도 |
|------|------|
| `rg`, `fd` | 빠른 파일/텍스트 탐색 |
| `jq`, `yq` | JSON, YAML, TOML 주변 설정 확인 |
| `mgrep` | semantic local search와 Codex MCP 연동 |
| Tavily MCP | 최신 웹 검색과 페이지 추출 |
| Exa MCP | 고품질 웹/리서치 검색과 근거 수집 |
| `ast-grep` (`sg`) | AST 기반 코드 패턴 탐지 |
| `semgrep` (`sgrep` 호환 확인) | 보안/정적 분석 룰 기반 스캔 |
| `difftastic` (`difft`) | 포맷 노이즈를 줄인 구조적 diff |
| `gitleaks` | 시크릿 스캔 |
| `scc` | 코드 통계와 복잡도 분석 |
| `shellcheck`, `shfmt` | hook/install 스크립트 품질 검증 |
| `osv-scanner` | 의존성 취약점 확인 |
| `uv`, `ruff`, `pnpm` | Python/Node 프로젝트 검증과 빠른 로컬 툴 실행 |
| `git-delta` | diff 가독성 개선 |
| `az` (`azure-cli`) | Azure 리소스 검토, 비용 산정, 운영 모니터링 |

`mgrep install-codex`는 semantic search를 위해 작업 디렉터리 파일을 Mixedbread 쪽으로 동기화할 수 있습니다. 민감한 저장소에서는 조직 정책을 확인한 뒤 켜세요.

Tavily/Exa MCP는 API 키를 repo에 저장하지 않습니다. installer는 `TAVILY_API_KEY`, `EXA_API_KEY` 환경변수를 먼저 보고, 없으면 기존 `~/.mcp.json`의 `tavily`/`exa` 항목에서 읽도록 Codex MCP 설정을 구성합니다.

## Codex Plugin 구조

이 저장소는 레포 루트 자체가 Codex plugin root입니다.

| 파일 | 역할 |
|------|------|
| `.codex-plugin/plugin.json` | Codex plugin manifest. `skills`, `hooks`, `mcpServers` 경로를 선언 |
| `.mcp.json` | plugin 설치 시 사용할 `mgrep`, Tavily, Exa MCP 설정 |
| `.agents/plugins/marketplace.json` | 로컬 marketplace. `source.path`가 이 레포 루트 `./`를 가리킴 |

즉, 배포용으로는 Codex plugin metadata를 갖고 있고, 로컬 적용은 `install.sh`가 현재 `~/.codex` 구조에 복사/등록합니다.

## 설치되는 것

```text
~/.codex/
├── config.toml                         # features, skills, hooks, agents 관리 블록
├── skills/                             # 47개 Codex skills
├── agents/                             # 15개 custom agent TOML
├── hooks/                              # 27개 lifecycle hook command 등록
├── rules/                              # Git/workflow 규칙
├── scripts/                            # 설치 검증, packets, healthcheck, log analysis, scheduler controls
```

프로젝트별 런타임 로그는 작업 중인 저장소의 `.codex-lattice/` 아래에 쌓입니다.

```text
.codex-lattice/
├── git-strategy.md
├── logs/events.jsonl
├── commits/*.json
├── commits/*.md
├── docs-sync-queue.jsonl
├── simplify-state.json
└── model-visible/
    ├── MAJOR_ERRORS.md
    ├── SIMPLIFY_REQUIRED.md
    ├── DOCS_AGENT_REQUIRED.md
    └── REFLECTION_REQUIRED.md
```

## 항상 켜지는 Hooks

이 항목들은 사용자가 `$skill`을 부르지 않아도 Codex lifecycle에서 동작합니다.

| Hook | 역할 |
|------|------|
| `codex-git-strategy-log.sh` | 매 작업 시작 시 브랜치, 커밋 분리, 검증, 롤백 전략 기록 |
| `codex-event-log.sh` | Session, prompt, tool, compact, stop 이벤트를 JSONL로 기록 |
| `codex-commit-log.sh` | `git commit` 후 커밋 메타데이터를 JSON/Markdown으로 저장 |
| `codex-major-error-log.sh` | 반복되거나 막히는 에러를 모델이 읽을 수 있는 `MAJOR_ERRORS.md`에 기록 |
| `codex-docs-sync-log.sh` | 변경 파일을 docs 동기화 큐에 남기고 docs agent gate를 표시 |
| `codex-simplify-gate.sh` | 코드 diff 누적, 큰 변경, HITL/Stop 직전에 simplify gate를 표시 |
| `codex-reflection-reminder.sh` | 복잡한 순차 지시나 compact 이후 reflection gate를 표시 |
| `codex-visible-error-reminder.sh` | 세션/compact 이후 주요 에러 로그 확인을 유도 |
| `codex-git-guard.sh` | force push, protected branch 직접 push, `.env` 커밋 같은 위험 작업 차단 |

`codex-prettier.sh`는 포맷터 연동을 위한 예비 스크립트이며 기본 lifecycle hook에는 등록하지 않습니다.

## Context / Review / Health Packets

Codex가 작업을 시작하거나 리뷰/종료 지점에 도달하면, 하네스가 작은 model-visible 패킷을 갱신합니다. 이 파일들은 전체 로그를 모델 컨텍스트에 넣지 않고도 필요한 증거만 보게 하기 위한 라우팅 표면입니다.

| Packet | 생성 위치 | 목적 |
|--------|-----------|------|
| Context Packet | `.codex-lattice/model-visible/CONTEXT_PACKET.md` | 현재 브랜치, dirty files, 읽을 파일 후보, validation 후보, 검색 라우팅 |
| Review Packet | `.codex-lattice/model-visible/REVIEW_PACKET.md` | diff stat, 위험 파일 분류, gate 상태, validation evidence, 리뷰 체크리스트 |
| Harness Health | `.codex-lattice/model-visible/HARNESS_HEALTH.md` | hook/config/log/gate/scheduler 상태와 attention item |
| Run Episode | `.codex-lattice/runs/<session>/` | context/review packet을 작업 단위로 보존 |

패킷은 read-only 관찰만 수행합니다. 사용자 입력을 shell로 실행하지 않고, `.env`, token, credential 같은 민감 경로는 읽기 후보에서 제외합니다.

## 선택형 Scheduled Operations

Codex 자체에는 cron 같은 scheduler가 없으므로 Codex Lattice는 외부 스케줄러를 사용합니다. 기본값은 **꺼짐**이며, 켜고 끄는 명령을 제공합니다.

```bash
# 1회 실행: deterministic healthcheck + log analysis
./scripts/codex-lattice-scheduler.sh run

# macOS launchd로 주기 실행 켜기
./scripts/codex-lattice-scheduler.sh enable

# 상태 확인
./scripts/codex-lattice-scheduler.sh status

# 주기 실행 끄기
./scripts/codex-lattice-scheduler.sh disable
```

기본 실행은 모델을 호출하지 않습니다. `CODEX_LATTICE_USE_CODEX=1`을 설정하면 생성된 health/log summary만 `codex exec --sandbox read-only`로 요약합니다.

## HITL 전 게이트

코드 변경이 생기면 hook이 자동 수정하지 않고, 모델이 봐야 할 gate 파일을 만듭니다.

| Gate | 생성 파일 | 처리 |
|------|-----------|------|
| reflection gate | `.codex-lattice/model-visible/REFLECTION_REQUIRED.md` | 최신 지시, 순서, 의존성, 완료 기준을 재확인 |
| simplify gate | `.codex-lattice/model-visible/SIMPLIFY_REQUIRED.md` | HITL, 리뷰, PR 전 단순화/정규화와 재검증 수행 |
| docs agent gate | `.codex-lattice/model-visible/DOCS_AGENT_REQUIRED.md` | `docs_maintainer` 또는 부모 에이전트가 관련 문서를 실제 diff에 맞춰 갱신 |

docs gate는 변경 파일 성격에 따라 아래 문서를 요구합니다.

| 문서 | 목적 |
|------|------|
| `PRODUCT_BRIEF.md` | PRD 반영 전 문제, 사용자, 범위, 비목표, 미결 질문 |
| `FEATURE_SPEC.md` | 기능 동작과 acceptance criteria |
| `API_SPEC.md` | endpoint, request/response, validation, error contract |
| `INFRA_SPEC.md` | 리소스, 설정, 운영, 모니터링 |
| `SECURITY_POLICY.md` | trust boundary, auth, data, secret, abuse/failure mode |
| `AGENT_SECURITY.md` | MCP, hook, plugin, sub-agent, prompt injection, excessive agency 위험 |
| `DATA_MODEL.md` | entity, ownership, persistence, normalization |
| `DATA_GOVERNANCE.md` | classification, privacy, retention, access control, audit |
| `TEST_PLAN.md` | unit, integration, E2E, regression, manual checks |
| `OBSERVABILITY.md` | logs, metrics, alerts, dashboards, incident signals |
| `OPERATIONS_RUNBOOK.md` | SLO, monitoring checklist, alert response, rollback, incident review |
| `SLO_POLICY.md` | SLIs, SLO target, error budget, release freeze, alert policy |
| `INCIDENT_RESPONSE.md` | severity, triage, mitigation, communication, follow-up |
| `POSTMORTEM_TEMPLATE.md` | blameless timeline, root cause, corrective action |
| `SUPPLY_CHAIN.md` | dependency policy, SBOM, provenance, vulnerability, license |
| `COST_MODEL.md` | cost drivers, budgets, Azure resource review, waste reduction |
| `MIGRATION_PLAN.md` | compatibility, data migration, rollback, verification |
| `RELEASE_PLAN.md` | version, rollout, backout, operator notes |
| `UX_SPEC.md` | flow, states, accessibility, responsive behavior |

## Codex 내장 기능 우선

Codex가 이미 잘하는 기능은 다시 만들지 않습니다.

| 먼저 쓸 것 | 언제 쓰나 | 하네스가 보강하는 것 |
|------------|-----------|----------------------|
| `/goal` | 긴 작업, 완료 조건, 중단/재개가 필요한 작업 | `docs/harness/TASKS.md`, `VALIDATION.md`에 진행 근거 유지 |
| `/plan` | 구현 전 계획과 리스크 분해 | 오래 남길 계획은 `$plan` 또는 실행 계획 문서로 승격 |
| `/review` | 현재 diff 빠른 리뷰 | 깊은 검토는 `$review`, `code_reviewer`, `security_reviewer` |
| `/diff` | 변경사항 확인 | `difft`, 커밋 후보 로그와 함께 사용 |
| `/compact` | 긴 세션 요약 | compact 전후 주요 에러와 작업 문서 확인 |
| `/agent` | sub-agent 상태 확인 | `.codex/agents/*.toml` 역할 지침 사용 |
| `/debug-config`, `/plugins`, `/mcp` | 설정/플러그인/MCP 진단 | 설치 스크립트와 검증 스크립트로 재현 가능하게 관리 |
| `$imagegen` | Codex 내장 이미지 생성 | installer가 `features.image_generation = true`를 켜서 built-in `image_gen` 툴을 사용할 수 있게 함 |

## 검색 라우팅

| 검색 종류 | 우선 도구 |
|-----------|-----------|
| 로컬 파일 의미 검색 | `mgrep` |
| 정확한 코드/텍스트 검색 | `rg`, 필요 시 `sg` |
| 최신 웹 검색/페이지 추출 | Tavily MCP |
| 근거 수집형 웹/리서치 검색 | Exa MCP |
| 공식 OpenAI 문서 | `openaiDeveloperDocs` MCP |

`&goal` 같은 별도 alias는 설치하지 않습니다. Codex 내장 명령은 `/goal`, 하네스 skill은 `$verify`처럼 구분합니다.

## Skills 47개

| Skill | 쓰는 상황 |
|-------|-----------|
| `$prd` | 아이디어를 CPS, PRD, MARKET, USERS, FEATURES, RISKS, SPEC, APPENDIX로 정리 |
| `$plan`, `$spec`, `$spec-verify` | 계획, 명세, 구현 완료도 검증 |
| `$autodev`, `$autodev-parallel` | `/goal` 기반 단일/병렬 자율 개발 루프 |
| `$verify`, `$review`, `$simplify`, `$techdebt` | 검증, 리뷰, 단순화, 기술부채 정리 |
| `$commit-push-pr`, `$handoff`, `$compact-guide` | 커밋/푸시/PR, 인계, 컨텍스트 관리 |
| `$build-fix`, `$tdd`, `$e2e-verify`, `$e2e-agent-browser` | 빌드 복구, TDD, E2E 검증 |
| `$frontend`, `$ui-ux-pro-max`, `$react-patterns`, `$shadcn-ui`, `$tailwind-design-system` | UI, React, Tailwind, 디자인 시스템 |
| `$harness-diagnostics`, `$harness-audit`, `$eval` | 하네스 점검, 감사, 품질 평가 |
| 운영/보안 스킬 | release readiness, incident response, observability/SLO, supply chain, agent tool risk, Azure FinOps, data governance, postmortem |
| 기술 스킬 | FastAPI, API 설계, async Python, pytest, TypeScript, Vercel React, Stitch, Nano Banana, Codex image, Microsoft Agent Framework, 계층형 plan memory |

## Custom Agents 15개

| Agent | 역할 |
|-------|------|
| `planner` | 범위, 순서, 리스크, 검증 기준 분해 |
| `architect` | 모듈 경계, 의존성 방향, 마이그레이션 위험 검토 |
| `frontend_developer` | UI, React, 접근성, 반응형 구현 |
| `junior_mentor` | 초보 개발자가 이해할 수 있는 구현 설명과 학습 문서 |
| `prd_planner` | CPS, PRD, SPEC 기획 산출물 합성 |
| `code_reviewer` | 버그, 회귀, 테스트 누락, 구조적 diff 리뷰 |
| `security_reviewer` | 시크릿, 권한, 입력 검증, 의존성 보안 |
| `azure_infra` | Azure CLI 기반 리소스 산정, 비용/보안/운영 검토, 모니터링, Azure memory 기록 |
| `db_query_specialist` | 데이터 모델 기반 SQL/ORM 쿼리 작성, 인덱스/트랜잭션/성능/안전성 리뷰 |
| `qa` | 사용자 시나리오와 검증 체크리스트 |
| `evaluator` | 독립 품질 점수화와 개선 루프 |
| `docs_writer` | 제품/기술 문서 작성 |
| `docs_maintainer` | `docs/harness/`를 실제 diff와 동기화 |
| `tdd_guide` | 테스트 우선 설계 |
| `stitch_developer` | Stitch 산출물의 React 변환 |

Custom agent는 `.codex/agents/*.toml`만 사용합니다. Markdown role 파일은 설치하지 않습니다.

## Sub-Agent 운용 규칙

Codex Lattice는 sub-agent를 자동 마법처럼 쓰지 않고, 부모 에이전트가 작업을 분해하고 검증하는 방식으로 씁니다.

| 원칙 | 내용 |
|------|------|
| bounded context | 부모가 task 본문, 파일 소유권, acceptance criteria, 검증 명령을 prompt에 직접 넣음 |
| status contract | implementer는 `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED` 중 하나로 보고 |
| review order | spec compliance를 먼저 확인하고, 통과 후 code quality/security/simplicity 검토 |
| no blind trust | sub-agent 보고를 그대로 믿지 않고 부모가 실제 diff와 검증 결과를 확인 |
| parallel safety | 병렬 구현은 write scope가 분리될 때만 허용 |

상세 규칙은 `docs/harness/SUBAGENT_PROTOCOL.md`에 있습니다.

## Repo 검증 명령

이 저장소를 수정한 뒤 PR 전에는 최소한 아래를 실행합니다.

```bash
bash scripts/check-codex-integrations.sh
bash -n install.sh
for f in hooks/codex-*.sh scripts/check-codex-integrations.sh; do bash -n "$f"; done
```

## 문제 해결

| 증상 | 처리 |
|------|------|
| `27 hooks need review before they can run` | `/hooks`에서 hook을 검토하고 trust 하세요. 첫 설치 후 한 번만 필요합니다. |
| `[features].codex_hooks is deprecated` | 오래된 설정입니다. `bash install.sh --ko`를 다시 실행하면 `features.hooks = true`로 정리됩니다. |
| `Skipped loading skill ... invalid YAML` | 최신 저장소를 pull 한 뒤 `bash install.sh --ko`를 다시 실행하고 Codex를 재시작하세요. |
| integration tool missing | `brew bundle --file Brewfile.codex`를 실행하세요. 일부 검사는 도구가 없으면 자동 skip 됩니다. |
| `mgrep` missing | `npm install -g @mixedbread/mgrep` 후 필요하면 `mgrep login`, `mgrep install-codex`를 실행하세요. |
| Tavily/Exa key missing | `TAVILY_API_KEY`, `EXA_API_KEY`를 환경변수로 두거나 기존 `~/.mcp.json`에 저장하세요. |
| `az` not logged in | `az login` 후 `az account show`로 현재 subscription을 확인하세요. |
| hook이 Active가 아님 | Codex 재시작 후 `/hooks`에서 Installed와 Active 숫자를 확인하세요. |

## 작업 문서 규칙

모든 코딩 작업은 최종 응답 전에 `docs/harness/`를 실제 diff와 검증 결과에 맞춰 갱신하는 것을 기본 정책으로 둡니다.

| 문서 | 기록할 내용 |
|------|-------------|
| `TASKS.md` | 현재 작업 범위와 상태 |
| `CHANGELOG.md` | 구현 변경사항 |
| `DECISIONS.md` | 결정과 이유 |
| `VALIDATION.md` | 실행한 검증, skip한 검증, 근거 |
| `RISKS.md` | 남은 위험, 후속 조치, 주요 에러 |

## 라이선스

MIT
