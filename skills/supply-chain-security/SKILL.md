---
name: supply-chain-security
description: "Software supply-chain security workflow. Use when dependencies, lockfiles, packages, build scripts, CI, SBOM, provenance, release artifacts, licenses, vulnerability scans, or third-party tools change."
---

# Supply Chain Security

Use this skill when dependencies, lockfiles, build/release scripts, CI, or third-party tools change.

## Workflow

1. Inspect changed dependency and build files.
2. Prefer lockfile-preserving installs and deterministic package managers.
3. Run available scanners:
   - `gitleaks detect --source . --no-git`
   - `osv-scanner .` when installed
   - language-specific audit commands when the project provides them
4. Check package provenance and maintainer risk for new critical dependencies.
5. Document SBOM/provenance expectations in `docs/harness/SUPPLY_CHAIN.md`.
6. Document unresolved vulnerabilities or accepted risk in `docs/harness/RISKS.md`.
7. Update `docs/harness/RELEASE_PLAN.md` when release artifacts or build integrity changes.

## Review Points

- New transitive dependency volume
- Typosquatting or abandoned packages
- Native install scripts or postinstall hooks
- Broad token permissions in CI
- Unpinned external actions or scripts
- License changes affecting distribution

## Required Output

Return changed supply-chain surface, scans run, findings, accepted risks, and release impact.
