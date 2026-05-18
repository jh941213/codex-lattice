---
name: prd
description: >
  Codex용 PRD/SPEC 작성 스킬. 아이디어를 CPS, PRD, 시장/사용자/기능/위험/SPEC 문서로 구조화한다.
  트리거: "$prd", "PRD 작성", "제품 기획", "아이디어 정리", "요구사항 문서", "CPS"
  안티-트리거: 이미 확정된 작은 코드 변경, 단순 버그 수정
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# PRD

Codex에서는 `$prd` 스킬로 기획 산출물을 만든다.

## 산출물

```text
prd/
├── CPS.md
├── PRD.md
├── MARKET.md
├── USERS.md
├── FEATURES.md
├── RISKS.md
├── SPEC.md
└── APPENDIX.md
```

## 절차

1. 기존 `prd/`가 있으면 이어서 진행할지 확인한다.
2. 복잡도 판정:
   - Low: 단순 기능/도구/CLI, 리서치 최소화.
   - Mid: 새 모듈/서비스/라이브러리, 핵심 리서치만 수행.
   - High: 새 제품/SaaS/플랫폼, 리서치와 인터뷰를 충분히 수행.
3. CPS를 먼저 확정한다:
   - Context: 어떤 상황/환경인가.
   - Problem: 어떤 문제가 있고 정량 지표는 무엇인가.
   - Solution: 성공 후 어떤 상태가 되어야 하는가.
4. 필요한 질문은 한 번에 1-3개만 한다.
5. 기능은 사용자 스토리, 인수조건, 우선순위, 제외 범위까지 쓴다.
6. SPEC에는 기술 스택, 아키텍처, API, 데이터 모델, 보안/배포 제약을 기록한다.
7. 마지막에 `FEATURES.md`와 `SPEC.md`가 서로 맞는지 검증한다.

## 리서치

시장/기술 정보가 최신성에 민감하면 공식 문서, GitHub, 웹 검색 결과를 확인하고 출처를 `APPENDIX.md`에 남긴다.

## 출력

```md
## PRD Result
- created/updated:
- unresolved questions:
- assumptions:
- next skill:
```
