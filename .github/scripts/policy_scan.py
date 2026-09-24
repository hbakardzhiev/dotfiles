#!/usr/bin/env python3
"""Static policy scan over tracked repository files.

Errors (exit 1):
  E1 plaintext-secret     `password = "..."` style assignments in Nix code
  E2 ssh-password-auth    sshd configured for password / keyboard-interactive
                          auth or PermitRootLogin = yes
  E3 impure-call          builtins.getEnv / builtins.currentSystem (breaks
                          pure flake evaluation)
  E4 unpinned-image       OCI container image without a digest or with :latest
  E5 unpinned-action      `uses:` in workflows not pinned to a full commit SHA

Warnings (annotations only):
  W1 insecure-url         plain http:// URL
  W2 sudo-no-password     security.sudo.wheelNeedsPassword = false
  W3 insecure-pkgs        permittedInsecurePackages / allowInsecurePredicate

Inline escape hatch: append `# policy-ok: E1` (rule id) to a line to allow it.
"""

from __future__ import annotations

import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from nixtext import comment_mask, line_col  # noqa: E402

NIX_RULES = {
    "E1": re.compile(
        r"(?i)\b(password|passwd|initialpassword|secretkey|apikey|api_key|"
        r"accesskey|token)\s*=\s*\"(?!\\?\$)"  # `"$var"` shell interpolation is fine
    ),
    "E2": re.compile(
        r"(?i)\b(PasswordAuthentication|KbdInteractiveAuthentication)\s*(?:=\s*)?"
        r"(?:true|\"?yes\"?)\b|\bPermitRootLogin\s*(?:=\s*)\"?yes\"?\b"
    ),
    "E3": re.compile(r"\bbuiltins\.(getEnv|currentSystem|currentTime)\b"),
    "E4": re.compile(r"\bimage\s*=\s*\"([^\"]+)\""),
    "W2": re.compile(r"\bwheelNeedsPassword\s*=\s*false\b"),
    "W3": re.compile(r"\b(permittedInsecurePackages|allowInsecurePredicate)\b"),
}

ANY_RULES = {"W1": re.compile(r"http://(?!localhost|127\.0\.0\.1|\$)")}

TEXT_EXT = {".nix", ".md", ".yml", ".yaml", ".toml", ".json", ".sh", ".txt"}
USES_RE = re.compile(r"^\s*(?:-\s+)?uses:\s*(\S+)", re.MULTILINE)


def tracked_files(root: str) -> list[str]:
    out = subprocess.run(
        ["git", "ls-files", "-z"], cwd=root, capture_output=True, check=True
    ).stdout
    return [f.decode() for f in out.split(b"\0") if f]


def policy_ok(line: str, rule: str) -> bool:
    return f"policy-ok: {rule}" in line


def scan_file(root: str, rel: str, errors, warnings):
    path = os.path.join(root, rel)
    ext = os.path.splitext(rel)[1]
    try:
        raw = open(path, encoding="utf-8").read()
    except (UnicodeDecodeError, OSError):
        return
    if "\0" in raw:
        return

    lines = raw.split("\n")
    mask = comment_mask(raw) if ext == ".nix" else None

    def line_masked(idx: int) -> bool:
        if mask is None:
            return False
        start = sum(len(l) + 1 for l in lines[:idx])
        line = lines[idx]
        first = len(line) - len(line.lstrip())
        if not line.strip():
            return False
        return all(mask[i] for i in range(start + first, start + len(line)))

    rules = dict(ANY_RULES)
    if ext == ".nix":
        rules.update(NIX_RULES)

    for idx, line in enumerate(lines):
        if mask is not None and line_masked(idx):
            continue  # whole-line comments are ignored
        for rule, pattern in rules.items():
            match = pattern.search(line)
            if not match:
                continue
            if policy_ok(line, rule):
                continue
            if rule == "E4":
                image = match.group(1)
                last = image.rsplit("/", 1)[-1]
                if ":" in last and not image.endswith(":latest"):
                    continue
            message = f"{rel}:{idx + 1}: [{rule}] {line.strip()[:160]}"
            if rule.startswith("E"):
                errors.append(message)
            else:
                warnings.append(message)

    # E5: actions must be pinned to a full commit SHA
    if rel.startswith(".github/workflows/"):
        for match in USES_RE.finditer(raw):
            ref = match.group(1).strip("'\"")
            if ref.startswith("./") or ref.startswith("docker://"):
                continue
            if not re.search(r"@[0-9a-f]{40}$", ref):
                line, _ = line_col(raw, match.start())
                errors.append(
                    f"{rel}:{line}: [E5] action {ref!s} is not pinned to a 40-char commit SHA"
                )


def main() -> int:
    root = os.environ.get("REPO_ROOT", ".")
    errors: list[str] = []
    warnings: list[str] = []

    for rel in tracked_files(root):
        if rel.startswith(".github/scripts/"):
            continue  # the policy itself lives here
        ext = os.path.splitext(rel)[1]
        if ext not in TEXT_EXT and not rel.startswith(".github/"):
            continue
        scan_file(root, rel, errors, warnings)

    for message in errors:
        print(f"::error::{message}")
    for message in warnings:
        print(f"::warning::{message}")
    print(f"policy scan: {len(errors)} errors, {len(warnings)} warnings")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
