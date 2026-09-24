#!/usr/bin/env python3
"""Cross-check sops secret references in Nix code against encrypted files.

Checks performed:
  E1  every literal `sops.secrets."name"` / `sops.placeholder."name"` reference
      resolves to a key in some secrets/**/secrets.yaml
  E2  every secrets/**/secrets.yaml is covered by a creation_rule in .sops.yaml
  E3  every `defaultSopsFile = ./path` / `sopsFile ? ./path` literal resolves
      to an existing file inside the repository
  W1  dynamically constructed references (`"${...}"`) are reported
  W2  keys that exist in secrets files but are never referenced (unless
      allowlisted in .github/sops-unused-allowlist.txt)

Exit code 1 if any error is found. Warnings become GitHub annotations.
"""

from __future__ import annotations

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from nixtext import comment_mask, line_col, without_comments  # noqa: E402

import yaml  # noqa: E402

SECRETS_GLOB = "secrets"
ALLOWLIST = ".github/sops-unused-allowlist.txt"

REF_RE = re.compile(r'\bsops\.(?:secrets|placeholder)\s*\.\s*"([^"]*)"')
FILE_RE = re.compile(r"\b(?:defaultSopsFile|sopsFile)\s*(?:\?|=)\s*(\.[A-Za-z0-9_./-]+)")


def flatten(data, prefix=""):
    out = set()
    for key, value in data.items():
        if not prefix and key == "sops":
            continue  # sops metadata (age recipients, mac, version, ...)
        path = f"{prefix}{key}"
        if isinstance(value, dict):
            out |= flatten(value, path + "/")
        else:
            out.add(path)
    return out


def find_secrets_files(root):
    files = []
    for dirpath, _dirnames, filenames in os.walk(os.path.join(root, SECRETS_GLOB)):
        for name in filenames:
            if name.startswith(".sops"):
                continue  # .sops.yaml is config, not a secrets file
            if name.endswith((".yaml", ".yml")):
                files.append(os.path.relpath(os.path.join(dirpath, name), root))
    return sorted(files)


def load_yaml(path):
    with open(path, encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def main() -> int:
    root = os.environ.get("REPO_ROOT", ".")
    errors: list[str] = []
    warnings: list[str] = []

    secrets_files = find_secrets_files(root)
    if not secrets_files:
        print("::error::no secrets files found under secrets/")
        return 1

    leaves: set[str] = set()
    for rel in secrets_files:
        data = load_yaml(os.path.join(root, rel))
        if not isinstance(data, dict):
            errors.append(f"{rel}: not a mapping")
            continue
        leaves |= flatten(data)

    # E2: .sops.yaml creation rules must cover every secrets file
    sops_yaml = os.path.join(root, "secrets", ".sops.yaml")
    if not os.path.exists(sops_yaml):
        errors.append("secrets/.sops.yaml is missing")
        rules = []
    else:
        rules = [
            rule.get("path_regex", "")
            for rule in (load_yaml(sops_yaml) or {}).get("creation_rules", [])
        ]
        for rel in secrets_files:
            if not any(re.search(pat, rel) for pat in rules if pat):
                errors.append(
                    f"{rel}: no creation_rule in secrets/.sops.yaml matches this file"
                )
        for pat in rules:
            if pat and not any(re.search(pat, rel) for rel in secrets_files):
                warnings.append(
                    f"secrets/.sops.yaml: creation_rule /{pat}/ matches no secrets file"
                )

    referenced: set[str] = set()
    dynamic: list[tuple[str, str]] = []

    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in (".git", "secrets")]
        for name in filenames:
            if not name.endswith(".nix"):
                continue
            path = os.path.join(dirpath, name)
            rel = os.path.relpath(path, root)
            text = open(path, encoding="utf-8").read()
            mask = comment_mask(text)

            def in_comment(start, end):
                return any(mask[i] for i in range(start, min(end, len(mask))))

            # E1/W1: secret references
            for match in REF_RE.finditer(text):
                if in_comment(match.start(), match.end()):
                    continue
                secret = match.group(1)
                line, _col = line_col(text, match.start())
                if "${" in secret:
                    dynamic.append((rel, f"{line}: {secret}"))
                    continue
                referenced.add(secret)
                if secret in leaves or any(
                    leaf.startswith(secret + "/") for leaf in leaves
                ):
                    continue
                errors.append(
                    f"{rel}:{line}: references sops secret {secret!r} "
                    "but no secrets file defines it"
                )

            # E3: sops file path literals must exist
            clean = without_comments(text)
            for match in FILE_RE.finditer(clean):
                raw = match.group(1)
                if "${" in raw:
                    continue
                resolved = os.path.normpath(
                    os.path.join(os.path.dirname(path) or ".", raw)
                )
                line, _col = line_col(text, match.start())
                if not os.path.exists(os.path.join(root, resolved)):
                    if os.path.exists(resolved):
                        continue  # absolute-ish path outside root, ignore
                    errors.append(
                        f"{rel}:{line}: sops file path {raw!r} does not exist "
                        f"(resolved to {resolved})"
                    )
                elif not os.path.realpath(resolved).startswith(
                    os.path.realpath(root) + os.sep
                ):
                    errors.append(f"{rel}:{line}: sops file path {raw!r} leaves the repo")

    # W2: unreferenced keys
    allowlist: set[str] = set()
    if os.path.exists(os.path.join(root, ALLOWLIST)):
        for line in open(os.path.join(root, ALLOWLIST), encoding="utf-8"):
            line = line.split("#", 1)[0].strip()
            if line:
                allowlist.add(line)
    else:
        warnings.append(f"{ALLOWLIST} is missing; every unused key will be reported")

    for leaf in sorted(leaves - referenced):
        if leaf in allowlist:
            continue
        warnings.append(f"unreferenced secret key: {leaf} (allowlist it if intentional)")

    for message in errors:
        print(f"::error::{message}")
    for message in warnings:
        print(f"::warning::{message}")
    for entry in dynamic:
        print(f"::notice::dynamically constructed sops reference (not verified): {entry}")

    print(
        f"sops cross-check: {len(secrets_files)} files, {len(leaves)} keys, "
        f"{len(referenced)} referenced, {len(dynamic)} dynamic, "
        f"{len(errors)} errors, {len(warnings)} warnings"
    )
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
