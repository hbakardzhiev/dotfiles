#!/usr/bin/env python3
"""Text hygiene for tracked files.

Rules:
  E1 no trailing whitespace in text files (.md .yml .yaml .toml .json .sh .txt)
  E2 every non-empty tracked text file ends with a newline
     (includes .nix; *.bak backups are exempt)
  E3 no UTF-8 BOM anywhere

Nix files are exempt from E1 because trailing spaces inside `''...''`
multi-line strings are real content (shell scripts, templates).
"""

from __future__ import annotations

import os
import subprocess
import sys

TEXT_EXT = {".md", ".yml", ".yaml", ".toml", ".json", ".sh", ".txt", ".py"}
ALWAYS_NEWLINE_EXT = TEXT_EXT | {".nix"}


def tracked_files(root: str) -> list[str]:
    out = subprocess.run(
        ["git", "ls-files", "-z"], cwd=root, capture_output=True, check=True
    ).stdout
    return [f.decode() for f in out.split(b"\0") if f]


def main() -> int:
    root = os.environ.get("REPO_ROOT", ".")
    errors: list[str] = []

    for rel in tracked_files(root):
        if rel.endswith(".bak"):
            continue
        path = os.path.join(root, rel)
        try:
            raw = open(path, "rb").read()
        except OSError:
            continue
        if b"\0" in raw:
            continue  # binary
        ext = os.path.splitext(rel)[1]

        if raw.startswith(b"\xef\xbb\xbf"):
            errors.append(f"{rel}: file starts with a UTF-8 BOM")

        if ext in TEXT_EXT:
            for lineno, line in enumerate(raw.split(b"\n"), 1):
                if line != line.rstrip(b" \t"):
                    errors.append(f"{rel}:{lineno}: trailing whitespace")

        if ext in ALWAYS_NEWLINE_EXT and raw and not raw.endswith(b"\n"):
            errors.append(f"{rel}: missing newline at end of file")

    for message in errors:
        print(f"::error::{message}")
    print(f"text hygiene: {len(errors)} errors")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
