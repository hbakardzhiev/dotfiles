#!/usr/bin/env python3
"""Check that flake.nix and flake.lock agree.

Checks:
  E1 every input declared in flake.nix `inputs = { ... }` exists in the lock
     file's root node, and the lock has no stray root inputs
  E2 every `X.inputs.Y.follows = "Z"` declared in flake.nix is honoured by
     the lock node for X
  W1 inputs without an explicit `follows` on nixpkgs (duplicate closures)

Exit code 1 on any error. No Nix required — pure text/JSON comparison.
"""

from __future__ import annotations

import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from nixtext import parse_flake_inputs, without_comments  # noqa: E402

FOLLOWS_RE = re.compile(
    r"(?:(\S+)\.)?inputs\.([A-Za-z0-9_-]+)\.follows\s*=\s*\"([^\"]+)\""
)


def main() -> int:
    root = os.environ.get("REPO_ROOT", ".")
    errors: list[str] = []
    warnings: list[str] = []

    flake_path = os.path.join(root, "flake.nix")
    lock_path = os.path.join(root, "flake.lock")
    if not os.path.exists(flake_path):
        print("::error::flake.nix missing")
        return 1
    if not os.path.exists(lock_path):
        print("::error::flake.lock missing")
        return 1

    text = open(flake_path, encoding="utf-8").read()
    inputs = parse_flake_inputs(text)
    lock = json.load(open(lock_path, encoding="utf-8"))
    root_node = lock.get("nodes", {}).get("root", {})
    locked_inputs: dict = root_node.get("inputs", {})

    # E1: declared inputs <-> lock root inputs
    declared = set(inputs)
    locked = set(locked_inputs)
    for name in sorted(declared - locked):
        errors.append(
            f"flake.nix declares input {name!r} but flake.lock has no root entry "
            "for it — the lock file is stale (run `nix flake update`)"
        )
    for name in sorted(locked - declared):
        errors.append(
            f"flake.lock root lists input {name!r} which flake.nix no longer "
            "declares — the lock file is stale (run `nix flake update`)"
        )

    # E2: declared follows must be honoured by the lock
    clean = without_comments(text)
    for match in FOLLOWS_RE.finditer(clean):
        owner, key, target = match.group(1), match.group(2), match.group(3)
        if owner is None:
            # `inputs.Y.follows` nested inside an input block: find enclosing
            span_owner = None
            for name, (start, end) in inputs.items():
                if start <= match.start() <= end:
                    if span_owner is None or (end - start) < (
                        inputs[span_owner][1] - inputs[span_owner][0]
                    ):
                        span_owner = name
            owner = span_owner
        if owner is None:
            errors.append(
                f"flake.nix: cannot attribute `inputs.{key}.follows` to an input"
            )
            continue
        node_name = locked_inputs.get(owner)
        node = lock.get("nodes", {}).get(node_name or "", {})
        actual = node.get("inputs", {}).get(key)
        if actual is None:
            errors.append(
                f"flake.nix: {owner}.inputs.{key}.follows = {target!r} but "
                f"flake.lock node {owner!r} has no follows for {key!r} "
                "— the lock file is stale"
            )
        else:
            actual_target = actual[0] if isinstance(actual, list) else actual
            expected = target.split("/")[0]
            if actual_target != expected:
                errors.append(
                    f"flake.nix: {owner}.inputs.{key} should follow {target!r} "
                    f"but flake.lock resolves it to {actual_target!r}"
                )

    # I1: inputs that pull their own nixpkgs (heavier eval, dup closures)
    for name in sorted(declared):
        node_name = locked_inputs.get(name)
        node = lock.get("nodes", {}).get(node_name or "", {})
        nix_follows = node.get("inputs", {}).get("nixpkgs")
        if nix_follows is not None and not isinstance(nix_follows, list):
            print(
                f"::notice::input {name!r} locks its own nixpkgs "
                f"({nix_follows!r}) instead of following a root input"
            )

    for message in errors:
        print(f"::error::{message}")
    for message in warnings:
        print(f"::warning::{message}")
    print(
        f"lock sync: {len(declared)} inputs declared, {len(locked)} locked, "
        f"{len(errors)} errors, {len(warnings)} warnings"
    )
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
