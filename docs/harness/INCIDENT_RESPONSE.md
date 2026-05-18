# Incident Response

Use this file during production incidents, major repeated tool failures, or operational regressions.

## Severity Levels

- SEV0: data loss, security exposure, destructive automation, or total outage.
- SEV1: customer-visible critical workflow outage.
- SEV2: partial degradation, failed deployment, or repeated operational failure.
- SEV3: non-urgent defect, flaky check, or noisy alert.

## Triage

- Incident commander:
- Start time:
- Detection source:
- Affected users/workflows:
- Current mitigation:
- Next update time:

## Mitigation

- Prefer rollback when it is lower risk than forward fix.
- Preserve logs and command output before cleanup.
- Avoid destructive commands until impact and rollback are clear.

## Communication

- Internal channel:
- External status:
- Stakeholders:
- Update cadence:

## Follow-Up

- Postmortem required:
- Corrective actions:
- Owner:
- Due date:
