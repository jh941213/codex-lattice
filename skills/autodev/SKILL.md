---
name: autodev
description: >
  Codex용 자율 개발 루프. PRD 항목을 하나씩 처리하며 명시적 검증과 커밋 후보 로그를 남긴다.
  트리거: "autodev", "자율 개발", "밤새 돌려", "/goal", "goal 기반 자동 개발", "자동 개발"
  안티-트리거: "직접 구현해", "한번만 해", "수동"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# AutoDev — Codex /goal 자율 개발

Codex용 자율 개발 루프. PRD/체크리스트의 항목을 하나씩 완료하고 검증 가능한 커밋 후보를 만든다.
장기 목표와 중단 조건은 Codex 내장 `/goal`에 둔다. 하네스는 진행 문서, 검증 로그, 커밋 후보 로그를 보강한다.

## 핵심 원리

```
/goal 설정 → PRD 읽기 → 다음 항목 처리 → 검증 → 커밋 후보 로그
                                                      ↓
                                             done_when 충족?
                                              ↓ Yes       ↓ No
                                         /goal clear   /goal 유지 후 재개
```

## Phase 0: 설정 수집

사용자에게 확인 (빠진 것만 질문):

```yaml
goal: "무엇을 달성할 것인가"           # 예: "PRD.md의 모든 항목 완료"
done_when: "완료 판단 기준"            # 예: "PRD의 모든 체크박스 완료 + npm test 통과"
prd: "PRD 또는 체크리스트 파일 경로"    # 예: "PRD.md" 또는 "tasks/todo.md"
scope: ["수정 가능한 파일 패턴"]        # 예: ["src/**", "tests/**"]
verify: "검증 명령어"                  # 예: "npm test" (자동 감지 가능)
max_iterations: 100                   # 최대 반복 수 (기본 100)
mode: "continue"                      # continue | reset (기본 continue)
```

### verify 자동 감지

사용자가 verify를 안 줬으면:
1. `package.json` → `npm test` 또는 `vitest run`
2. `pyproject.toml` → `pytest`
3. `Makefile` → `make test`
4. 없으면 → `echo "no verify command"`

## Phase 1: 루프 초기화

Codex 세션에서 먼저 목표를 설정한다:

```text
/goal {goal}; done_when={done_when}; scope={scope}; verify={verify}; docs=docs/harness/*
```

```bash
# 1. autodev 브랜치 생성
git checkout -b autodev/$(date +%Y%m%d-%H%M)

# 2. .codex-lattice/autodev/ 상태 디렉토리 생성
mkdir -p .codex-lattice/autodev

# 3. 상태 파일 초기화
cat > .codex-lattice/autodev/state.json << 'STATE'
{
  "active": true,
  "iteration": 0,
  "max_iterations": {max_iterations},
  "prompt": "{goal}",
  "done_when": "{done_when}",
  "prd_path": "{prd}",
  "verify_command": "{verify}",
  "started_at": "{ISO시간}",
  "status": "running"
}
STATE

# 4. .gitignore에 .codex-lattice/autodev/ 추가
echo ".codex-lattice/autodev/" >> .gitignore

# 5. 베이스라인 검증
{verify} 2>&1 | tee .codex-lattice/autodev/baseline.log
```

## Phase 2: 반복 실행 (매 세션)

각 세션(반복)에서 수행하는 절차:

```
1. READ PRD
   - {prd} 파일을 읽는다
   - 미완료 항목([ ]) 중 첫 번째를 선택

2. PLAN
   - 선택한 항목을 구현하기 위한 최소 변경 계획
   - scope 내 파일만 수정 가능

3. IMPLEMENT
   - 계획대로 코드 수정
   - scope 밖 파일 절대 수정 금지

4. VERIFY
   - {verify} 실행
   - 실패 시 build-fix 1회 시도
   - 2회 실패 시 작업 중단, diff와 실패 원인을 기록
   - 파괴적 롤백은 사용자 승인 없이 실행하지 않음

5. COMMIT
   - 성공 시:
     git add [specific-files]
     git commit -m "[autodev] {항목 요약}"
     .codex-lattice/commits/에 후보 로그 확인
   - PRD에서 해당 항목을 [x]로 체크

6. CHECK COMPLETION
   - PRD에 미완료 항목이 남아있는가?
   - Yes → `/goal`을 유지하고 다음 반복을 명시적으로 재개
   - No → done_when 충족. `docs/harness/`와 검증 결과를 갱신하고 `/goal clear`
```

## Phase 3: 완료 보고

루프 종료 시 (완료 또는 max_iterations 도달):

```markdown
# AutoDev 완료 보고서

## 요약
- 총 반복: {N}회
- 완료 항목: {K}/{total}
- 베이스라인 → 최종: 검증 통과
- 상태: {completed | max_iterations_reached}

## 완료된 항목
| # | 항목 | 커밋 |
|---|------|------|
| 1 | API 엔드포인트 구현 | abc1234 |
| 2 | 인증 추가 | def5678 |

## 미완료 항목 (있으면)
- [ ] 항목 N: 이유

## 브랜치
autodev/{tag} — main 머지 준비 완료
```

## 안전장치

1. **scope 밖 수정 금지**: scope에 명시된 파일/디렉토리만 수정
2. **기존 테스트 보호**: verify 실패 시 변경을 커밋하지 않고 diff와 실패 원인 기록
3. **crash 복구 제한**: build-fix 1회만. 2회 실패 시 해당 항목 스킵
4. **git 안전**: autodev/ 브랜치에서만 작업. main 절대 안 건드림
5. **max_iterations**: 무한 루프 방지 (기본 100)
6. **비용 인식**: 각 반복은 토큰 비용 발생. 반복 수를 합리적으로 설정

## Codex Hook 동작

`~/.codex/hooks/codex-*.sh`가 작업 이벤트를 기록한다:

- `.codex-lattice/logs/events.jsonl`: 이벤트 추적
- `.codex-lattice/git-strategy.md`: 반복 시작 시 Git 전략
- `.codex-lattice/model-visible/MAJOR_ERRORS.md`: 반복을 막는 주요 에러
- `.codex-lattice/docs-sync-queue.jsonl`: 문서 동기화 큐

Codex hooks는 새 작업을 자동 주입하지 않는다. 다음 반복은 `/goal`이 붙은 같은 목표로 사용자가 재개하거나 별도 스케줄러가 Codex를 다시 호출해야 한다.

## 수동 제어

```text
/goal                 # 현재 목표 확인
/goal pause           # 보류
/goal resume          # 재개
/goal clear           # 완료 또는 중단 후 정리
```

작업 진행 상태는 `docs/harness/TASKS.md`, 검증 근거는 `docs/harness/VALIDATION.md`, 반복 실패는 `docs/harness/RISKS.md`에 기록한다.

## 기존 스킬 활용

| 상황 | 사용 스킬 |
|------|----------|
| 빌드 실패 시 복구 | `build-fix` |
| 커밋 후 코드 정리 | `simplify` |
| 테스트 기반 구현 | `tdd` |
| 항목 구현 계획 | `plan` |
| 최종 검증 | `verify` |
