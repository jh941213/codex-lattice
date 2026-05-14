#!/usr/bin/env python3
"""Bootstrap structured project memory files for plan mode."""

from __future__ import annotations

import argparse
import os
from datetime import datetime
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Create structured plan memory .md files.")
    parser.add_argument(
        "--root",
        default=".",
        help="Project root to write .plan-memory into. Default: current directory",
    )
    parser.add_argument(
        "--project-name",
        default=None,
        help="Optional project name. Default: root folder name",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite existing files (default: skip existing files)",
    )
    return parser.parse_args()


def write(path: Path, content: str, force: bool) -> bool:
    if path.exists() and not force:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")
    return True


def now() -> str:
    return datetime.now().strftime("%Y-%m-%d")


def templates(project: str, created: str) -> dict[str, str]:
    return {
        "README.md": f"""# {project} Plan Memory\n\nThis folder stores project-level memory for /plan sessions.\n\n- Created: {created}\n- Last updated: {created}\n\n## Memory Layers\n\n- product: product objectives, acceptance criteria, scope boundaries\n- backend: API, data model, integration assumptions\n- frontend: UX flow, state, component and interaction assumptions\n- shared: cross-cutting constraints and glossary\n- execution: current plan, risks, open questions\n\n## Canonical Read Order for planning\n\n1. `product/requirements.md`\n2. `backend/requirements.md`\n3. `frontend/requirements.md`\n4. `shared/constraints.md`\n5. `execution/current-plan.md`\n\nUpdate this index whenever layer files are added or renamed.\n""",
        "product/requirements.md": """# Product Requirements\n\n## Problem\n-\n\n## Target Users\n-\n\n## Core Value\n-\n\n## In Scope\n-\n\n## Out of Scope\n-\n\n## Success Criteria\n-\n""",
        "product/acceptance-criteria.md": """# Acceptance Criteria\n\n## Must Have\n- [ ]\n- [ ]\n\n## Should Have\n- [ ]\n- [ ]\n\n## Nice to Have\n- [ ]\n- [ ]\n""",
        "backend/requirements.md": """# Backend Requirements\n\n## Core APIs\n- Endpoint list and ownership\n\n## Data Ownership\n-\n\n## Performance\n-\n\n## Security\n-\n""",
        "backend/api-contracts.md": """# API Contracts\n\n## Interface Conventions\n- Base path\n- Auth approach\n\n## Current Endpoints\n- `GET /`\n- `POST /`\n\n## Error Model\n-\n""",
        "backend/data-model.md": """# Data Model\n\n## Entities\n-\n\n## Validation Rules\n-\n\n## Migration Notes\n-\n""",
        "frontend/requirements.md": """# Frontend Requirements\n\n## User Journeys\n-\n\n## Accessibility\n-\n\n## Performance\n-\n\n## Browser Support\n-\n""",
        "frontend/ux-flow.md": """# UX Flow\n\n## Primary Screens\n-\n\n## Critical States\n-\n\n## Error and Loading Handling\n-\n""",
        "frontend/state-management.md": """# State and Interaction\n\n## Store Layout\n-\n\n## Caching Strategy\n-\n\n## API Consumption\n-\n""",
        "shared/constraints.md": """# Shared Constraints\n\n## Technical Constraints\n-\n\n## Compliance & Policy\n-\n\n## Operational Constraints\n-\n""",
        "shared/glossary.md": """# Glossary\n\n## Domain Terms\n- Term: definition\n\n## Acronyms\n- API: Application Programming Interface\n""",
        "execution/current-plan.md": """# Current Plan\n\n## Active Scope\n-\n\n## Milestones\n- [ ] \n- [ ] \n\n## Risks\n- [ ] \n\n## Open Questions\n- [ ] \n""",
        "execution/open-questions.md": """# Open Questions\n\n## Unresolved Items\n- [ ]\n- [ ]\n\n## Decision Logs\n- [ ]\n""",
    }


def main() -> int:
    args = parse_args()
    root = Path(args.root).expanduser().resolve()
    if not root.exists():
        raise SystemExit(f"Root does not exist: {root}")

    memory_root = root / ".plan-memory"
    project_name = args.project_name or root.name
    created = now()

    files = templates(project_name, created)
    changed = 0

    for rel_path, content in files.items():
        path = memory_root / rel_path
        if write(path, content, args.force):
            changed += 1
            print(f"wrote: {path}")

    if changed == 0:
        print("no changes: all files already exist (use --force to overwrite)")
        return 1

    readme = memory_root / "README.md"
    if readme.exists():
        existing = readme.read_text(encoding="utf-8")
        marker = "## Canonical Read Order for planning"
        if marker in existing:
            updated = existing.replace("- Last updated: " + created + "\\n", "- Last updated: " + now() + "\\n")
            write(readme, updated, True)

    print(f"created/updated: {memory_root}")
    print(f"files written: {changed}/{len(files)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
