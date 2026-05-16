# AGENTS.md

Codex 작업자는 이 저장소를 Codex용 에이전트 하네스로 유지한다.

## Codex Lattice Rules
- 매 작업 시작 시 이 문서를 기준으로 Git 전략을 먼저 정한다: 현재 브랜치, 변경 범위, 커밋 분리 기준, 검증 명령, 롤백 방식.
- 작업 단위가 커밋 가능해지면 `.codex-lattice/commits/`에 커밋 후보 로그를 남긴다.
- 모든 hook 이벤트는 `.codex-lattice/logs/events.jsonl`에 기록한다. 이 파일은 운영 추적용이며 모델 컨텍스트로 먼저 읽지 않는다.
- 주요 에러가 반복되거나 작업을 막으면 `.codex-lattice/model-visible/MAJOR_ERRORS.md`를 갱신한다. 재시도 전 이 파일은 모델이 읽어야 한다.
- 여러 지시를 순차 처리하거나 compact 이후 재개할 때는 `docs/harness/REFLECTION.md`를 읽고 최신 사용자 요청 기준으로 방향을 재확인한다.
- 코딩 작업 중 변경된 구현과 문서는 함께 움직여야 한다. 모든 작업은 최종 응답 전 `docs/harness/`를 실제 diff와 검증 결과에 맞춰 갱신한다.
- 숨은 지식 금지: 반복되는 운영 규칙은 hook, 스크립트, 또는 이 문서에 남긴다.

## Always-On Harness
- Git 전략, 작업 로그, 주요 에러 로그, docs sync는 사용자가 호출하는 스킬이 아니라 모든 작업의 기본 루프다.
- `hooks/codex-git-strategy-log.sh`는 작업 시작 프롬프트를 기준으로 Git 전략 초안을 남긴다. 에이전트는 실제 변경 전 이 전략을 확인하고 필요하면 보정한다.
- `hooks/codex-docs-sync-log.sh`는 diff가 생기면 `.codex-lattice/docs-sync-queue.jsonl`에 동기화 큐를 남긴다. 에이전트는 최종 응답 전 이 큐를 반영해 `docs/harness/`를 갱신한다.
- `hooks/codex-simplify-gate.sh`는 코드 diff가 누적되거나 HITL/Stop 직전에 `.codex-lattice/model-visible/SIMPLIFY_REQUIRED.md`를 남긴다. 에이전트는 사람에게 넘기기 전에 단순화/정규화와 재검증을 끝낸다.
- `hooks/codex-reflection-reminder.sh`는 복잡한 순차 지시나 compact 이후 `.codex-lattice/model-visible/REFLECTION_REQUIRED.md`를 남긴다. 에이전트는 `docs/harness/REFLECTION.md`를 읽고 instruction ledger를 재구성한 뒤 계속한다.
- 코드 diff가 생기면 `.codex-lattice/model-visible/DOCS_AGENT_REQUIRED.md`를 확인한다. sub-agent 사용이 가능한 실행에서는 `docs_maintainer`로 기능명세/API 명세/인프라 정의/검증 문서를 맞추고, 불가능하면 부모 에이전트가 직접 갱신한다.
- sub-agent를 쓰는 작업은 `docs/harness/SUBAGENT_PROTOCOL.md`를 따른다. 부모 에이전트가 plan/task/context를 추출해 전달하고, sub-agent에게 긴 계획 파일을 알아서 읽게 하지 않는다.
- hidden logs는 기본 컨텍스트가 아니다. 장애 분석, 재시도, 감사 요청 때만 읽는다.

## Reflection Guard
- 최신 사용자 메시지가 항상 우선한다. 이전 목표, 이전 계획, compact 요약, hidden log가 최신 지시를 덮어쓰면 안 된다.
- 다단계 작업은 시작 전 `docs/harness/REFLECTION.md`의 instruction ledger를 만든다: 최신 요청, 순서, 의존성, 금지사항, 현재 단계, 완료 기준.
- 주요 단계가 끝날 때마다 다음 행동이 최신 요청과 맞는지 확인한다. 어긋나면 즉시 멈추고 방향을 바로잡는다.
- 최종 응답 전에는 newest-request check를 수행한다. 완료, 생략, 보류, 검증, git 상태를 최신 요청 기준으로 말한다.
- 모호하지만 안전한 로컬 관례가 있으면 진행하고 가정을 문서화한다. 비용, 보안, 데이터 손실, git history가 걸리면 사용자에게 확인한다.

## HITL Gates
- 사람에게 승인, 리뷰, PR 판단을 요청하기 전에 reflection gate, simplify gate, docs agent gate를 통과해야 한다.
- reflection gate는 코드를 자동 수정하지 않는다. 모델이 최신 지시, 순서, 의존성, 현재 단계, 완료 기준을 재확인한다.
- simplify gate는 코드를 자동 수정하지 않는다. 모델이 `$simplify` 체크리스트 또는 동일 원칙으로 직접 정리하고 검증한다.
- docs agent gate는 코드를 자동 문서화하지 않는다. `docs_maintainer` 또는 부모 에이전트가 실제 diff 기준으로 제품 맥락, 기능명세, API 명세, 인프라 정의, 보안정책, 데이터 모델, 테스트 계획, 관측성, 운영 런북, 마이그레이션, 릴리즈, UX 문서를 갱신한다.
- gate를 통과하지 못하고 HITL이 필요한 경우, `docs/harness/RISKS.md`에 이유와 남은 작업을 먼저 남긴다.

## Codex Built-ins First
- 표기 규칙: Codex 내장 명령은 `/goal`처럼 `/`, 하네스 skill은 `$prd`처럼 `$`를 사용한다. `&goal` alias는 만들지 않는다.
- 장기 목표와 중단 조건은 커스텀 루프보다 `/goal <objective>`를 먼저 사용한다. 완료 또는 보류 시 `/goal clear`, `/goal pause`, `/goal resume`으로 상태를 정리한다.
- 구현 전 탐색 계획은 내장 `/plan`을 먼저 쓰고, 지속 문서가 필요할 때만 `$plan` 또는 `docs/harness/TASKS.md`로 승격한다.
- 일반 변경 리뷰는 `/review`로 빠르게 시작하고, AST/보안/복잡도까지 필요한 경우 `$review`와 `code_reviewer`를 추가한다.
- 변경 확인은 `/diff`, 긴 대화 정리는 `/compact`, 실행 상태 확인은 `/status`와 `/ps`, 백그라운드 중단은 `/stop`을 우선 사용한다.
- agent thread 전환과 점검은 `/agent`, 플러그인과 MCP 점검은 `/plugins`, `/mcp`, 설정 진단은 `/debug-config`를 우선 사용한다.
- 웹 검색이 필요하면 Tavily MCP를 최신 검색/페이지 추출에 우선 사용하고, 근거 수집형 리서치에는 Exa MCP를 사용한다. OpenAI 제품/API는 `openaiDeveloperDocs` MCP를 우선한다.
- 로컬 의미 검색은 `mgrep`, 정확한 코드 검색은 `rg`, 구조 패턴 검색은 `sg`를 사용한다.

## Long-Running Goals
- 한 턴을 넘기는 작업은 시작 프롬프트에 `/goal` objective, done_when, 주요 파일, 검증 명령, 산출 문서를 명시한다.
- 모델이 볼 진행 상태는 `docs/harness/TASKS.md`와 `docs/harness/VALIDATION.md`에 남긴다. 숨은 이벤트 로그를 진행판으로 쓰지 않는다.
- `/goal`은 목표 유지 장치이고 자동 승인 루프가 아니다. destructive git, 권한, 제품 판단은 사용자 확인이 필요하다.

## Skill Routing
- 요구사항이 제품/기획 수준이면 `prd`; 구현 명세가 필요하면 `spec`; 3단계 이상 구현 계획은 `plan`.
- 테스트 우선 구현: `tdd`; 완료 검증: `verify`; 빌드 실패 복구: `build-fix`.
- 리뷰 요청: `review`; 커밋/푸시/PR 요청: `commit-push-pr`.
- UI 작업: `frontend`, `ui-ux-pro-max`, 필요 시 `react-patterns`, `shadcn-ui`, `tailwind-design-system`.
- 긴 스킬은 필요한 섹션만 읽는다. 관련 없는 reference 파일을 한꺼번에 로드하지 않는다.
- 하네스 통합 점검은 `scripts/check-codex-integrations.sh` 또는 설치 후 `~/.codex/scripts/check-codex-integrations.sh`를 사용한다.

## Sub-Agent Routing
- 원칙: 부모 에이전트가 orchestration을 소유한다. sub-agent는 명확한 파일 소유권, acceptance criteria, 검증 명령, 보고 형식을 받은 bounded task만 수행한다.
- 구현 sub-agent는 `DONE`, `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED` 중 하나로 보고한다. `DONE_WITH_CONCERNS`, `NEEDS_CONTEXT`, `BLOCKED`는 무시하지 말고 context 보강, task 분할, 더 강한 모델/agent, 또는 사용자 확인으로 조건을 바꾼 뒤 재시도한다.
- sub-agent가 작성한 코드는 부모가 실제 diff와 검증 결과로 확인한다. implementer 보고만 믿지 않는다.
- 코드 작성 후 review는 가능하면 두 단계로 나눈다: 먼저 spec compliance, 그 다음 code quality/security/simplicity.
- 병렬 구현은 write scope가 분리될 때만 허용한다. 모든 worker에게 다른 agent의 변경을 되돌리지 말고 파일 소유권을 지키라고 명시한다.
- `planner`: 구현 순서, 위험, 검증 기준을 분해해야 할 때.
- `architect`: 모듈 경계, 레이어 의존성, 큰 구조 변경을 검토할 때.
- `frontend_developer`: UI 구현이나 접근성/반응형 품질이 핵심일 때.
- `junior_mentor`: 구현 결과를 초보자용 학습 문서로 설명해야 할 때.
- `prd_planner`: CPS/PRD/SPEC 산출물을 합성해야 할 때.
- `code_reviewer`: 구현 후 버그, 회귀, 테스트 누락을 찾을 때.
- `security_reviewer`: 인증, 권한, 입력 검증, 시크릿, 의존성 보안이 걸릴 때.
- `qa`: 사용자 시나리오와 검증 체크리스트가 필요할 때.
- `evaluator`: 작업 결과를 독립 점수화하거나 개선 루프를 정리할 때.
- `docs_maintainer`: 구현 변경 후 `docs/harness/`를 실제 diff와 맞출 때.
- LangChain, LangGraph, Deep Agents 판단은 custom agent가 아니라 관련 skills와 공식 문서 조회로 처리한다.
- 서브에이전트는 사용자가 요청했거나 현재 Codex 실행 지침상 허용되는 범위에서만 사용한다. 병렬 작업은 파일 소유권이 분리될 때만 맡긴다.

## Git Strategy Template
```md
## Git Strategy
- branch:
- scope:
- commit split:
- validation:
- rollback:
```

## Log Locations
- Hidden event log: `.codex-lattice/logs/events.jsonl`
- Git strategy log: `.codex-lattice/git-strategy.md`
- Commit candidate logs: `.codex-lattice/commits/*.json` and `.codex-lattice/commits/*.md`
- Model-visible major errors: `.codex-lattice/model-visible/MAJOR_ERRORS.md`
- Model-visible reflection gate: `.codex-lattice/model-visible/REFLECTION_REQUIRED.md`
- Model-visible work docs: `docs/harness/*.md`
- Docs sync queue: `.codex-lattice/docs-sync-queue.jsonl`

## Docs Maintenance
- `docs/harness/TASKS.md` tracks current scope and status.
- `docs/harness/PRODUCT_BRIEF.md` records problem, users, scope, non-goals, and open questions before PRD.
- `docs/harness/FEATURE_SPEC.md` records feature behavior and acceptance criteria.
- `docs/harness/API_SPEC.md` records endpoint, request/response, validation, and error contracts.
- `docs/harness/INFRA_SPEC.md` records resources, configuration, operations, monitoring, and rollout notes.
- `docs/harness/SECURITY_POLICY.md` records trust boundaries, auth, data handling, secrets, and abuse/failure modes.
- `docs/harness/DATA_MODEL.md` records entities, ownership, persistence, and normalization rules.
- `docs/harness/TEST_PLAN.md` records unit, integration, E2E, regression, and manual checks.
- `docs/harness/OBSERVABILITY.md` records logs, metrics, alerts, dashboards, and incident signals.
- `docs/harness/OPERATIONS_RUNBOOK.md` records SLOs, monitoring checklist, alert response, rollback, and incident review.
- `docs/harness/MIGRATION_PLAN.md` records compatibility, data migration, rollback, and verification.
- `docs/harness/RELEASE_PLAN.md` records version, rollout, backout, and user/operator notes.
- `docs/harness/UX_SPEC.md` records flows, states, accessibility, and responsive behavior.
- `docs/harness/REFLECTION.md` records drift checks for sequential work, interruptions, compact resume, and final response.
- `docs/harness/SUBAGENT_PROTOCOL.md` records Codex-native delegation, review ordering, report statuses, and parallel ownership rules.
- `docs/harness/DECISIONS.md` records decisions future agents need.
- `docs/harness/CHANGELOG.md` summarizes implementation changes.
- `docs/harness/VALIDATION.md` records checks and skipped checks.
- `docs/harness/RISKS.md` captures remaining risks and major repeated errors.
