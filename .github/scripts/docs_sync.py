#!/usr/bin/env python3
"""Keep .github/README.md in sync with the workflow inventory.

Checks:
  E1 every workflow file is mentioned by name in .github/README.md
  E2 every workflow file has a status badge in .github/README.md
  E3 every workflow badge in .github/README.md points at an existing workflow
  E4 .github/README.md keeps a `## CI` section
"""

from __future__ import annotations

import glob
import os
import re
import sys

BADGE_RE = re.compile(r"actions/workflows/([A-Za-z0-9._-]+)/badge\.svg")


def main() -> int:
    root = os.environ.get("REPO_ROOT", ".")
    readme_path = os.path.join(root, ".github", "README.md")
    errors: list[str] = []

    if not os.path.exists(readme_path):
        print("::error::.github/README.md is missing")
        return 1
    readme = open(readme_path, encoding="utf-8").read()

    workflows = sorted(
        os.path.basename(p)
        for p in glob.glob(os.path.join(root, ".github", "workflows", "*.yml"))
        + glob.glob(os.path.join(root, ".github", "workflows", "*.yaml"))
    )

    for wf in workflows:
        if wf not in readme:
            errors.append(f".github/README.md does not mention workflow {wf}")
        if f"actions/workflows/{wf}/badge.svg" not in readme:
            errors.append(f".github/README.md has no status badge for {wf}")

    for badge in sorted(set(BADGE_RE.findall(readme))):
        if badge not in workflows:
            errors.append(
                f".github/README.md has a badge for unknown workflow {badge}"
            )

    if not re.search(r"^##\s+CI\s*$", readme, re.MULTILINE):
        errors.append(".github/README.md lost its `## CI` section")

    for message in errors:
        print(f"::error::{message}")
    print(f"docs sync: {len(workflows)} workflows, {len(errors)} errors")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
