"""Comment/string-aware helpers for parsing Nix source text."""

import re


def comment_mask(text: str) -> list[bool]:
    """Return a mask where True means the character sits inside a `#` comment.

    Understands `"..."` strings, `''...''` multi-line strings, char literals
    and backslash escapes, so `#` inside shell snippets embedded in Nix
    strings is not treated as a comment.
    """
    mask = [False] * len(text)
    i, n = 0, len(text)
    NORMAL, DOUBLE, MULTILINE = 0, 1, 2
    state = NORMAL
    while i < n:
        c = text[i]
        if state == NORMAL:
            if c == "#":
                while i < n and text[i] != "\n":
                    mask[i] = True
                    i += 1
            elif c == '"':
                state = DOUBLE
                i += 1
            elif c == "'" and i + 1 < n and text[i + 1] == "'":
                state = MULTILINE
                i += 2
            elif c == "'":
                closing = text.find("'", i + 1)
                i = n if closing == -1 else closing + 1
            else:
                i += 1
        elif state == DOUBLE:
            if c == "\\":
                i += 2
            elif c == '"':
                state = NORMAL
                i += 1
            else:
                i += 1
        else:  # MULTILINE
            if c == "'" and i + 1 < n and text[i + 1] == "'":
                nxt = text[i + 2] if i + 2 < n else ""
                # ''' and ''${ are escapes inside multi-line strings
                if nxt in ("'", "$"):
                    i += 2
                else:
                    state = NORMAL
                    i += 2
            else:
                i += 1
    return mask


def without_comments(text: str) -> str:
    """Blank out comment characters, preserving offsets and newlines."""
    mask = comment_mask(text)
    return "".join(" " if m else c for c, m in zip(text, mask))


def line_col(text: str, offset: int) -> tuple[int, int]:
    """1-based (line, column) for a character offset."""
    line = text.count("\n", 0, offset) + 1
    start = text.rfind("\n", 0, offset) + 1
    return line, offset - start + 1


def parse_flake_inputs(text: str) -> dict[str, tuple[int, int]]:
    """Parse `inputs = { ... }` from flake.nix.

    Returns an ordered mapping of input name -> (start, end) character span of
    the input's right-hand side (block or scalar), comment characters blanked
    out of the original text positions.
    """
    clean = without_comments(text)
    m = re.search(r"\binputs\s*=\s*\{", clean)
    if not m:
        return {}
    open_brace = clean.index("{", m.start())
    inputs: dict[str, tuple[int, int]] = {}
    depth = 1
    i = open_brace + 1
    n = len(clean)
    key_re = re.compile(r'\s*("(?:[^"\\]|\\.)*"|[A-Za-z_][A-Za-z0-9_.\'-]*)\s*=')
    while i < n and depth > 0:
        c = clean[i]
        if c == "{":
            depth += 1
            i += 1
        elif c == "}":
            depth -= 1
            i += 1
        elif depth == 1:
            km = key_re.match(clean, i)
            if km:
                raw_name = km.group(1)
                if raw_name.startswith('"'):
                    name = raw_name.strip('"')
                else:
                    # dotted paths like `nixpkgs.url = ...` belong to `nixpkgs`
                    name = raw_name.split(".", 1)[0]
                value_start = km.end()
                # scan the value: attrset block, list, string, or scalar up to ';'
                j = value_start
                vdepth = 0
                while j < n:
                    ch = clean[j]
                    if ch in "{[(":
                        vdepth += 1
                    elif ch in "}])":
                        if vdepth == 0 and ch == "}":
                            break  # end of the inputs block
                        vdepth -= 1
                    elif ch == ";" and vdepth == 0:
                        break
                    elif ch == '"' and vdepth == 0:
                        j += 1
                        while j < n and clean[j] != '"':
                            j += 2 if clean[j] == "\\" else 1
                    elif ch == '"' and vdepth > 0:
                        j += 1
                        while j < n and clean[j] != '"':
                            j += 2 if clean[j] == "\\" else 1
                    j += 1
                if name in inputs:
                    prev_start, prev_end = inputs[name]
                    inputs[name] = (min(prev_start, value_start), max(prev_end, j))
                else:
                    inputs[name] = (value_start, j)
                i = j
            elif c in " \t\n\r;,":
                i += 1
            else:
                i += 1
        else:
            i += 1
    return inputs
