#!/usr/bin/env bash
# ScoutPanel takes colours and spacing from the theme
set -u

python3 - <<'PY'
import json, os, re, sys

APP = "/home/candidate/backstage-app"
PLUGIN = "plugins/scout-status"
SRC = PLUGIN + "/src"


def fail(message):
    print("FAIL: " + message)
    sys.exit(1)


def ok(message):
    print("OK: " + message)
    sys.exit(0)


def strip(text):
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    return re.sub(r"(^|\s)//.*$", "", text, flags=re.M)


def read(rel):
    path = os.path.join(APP, rel)
    if not os.path.isfile(path):
        fail("missing file " + rel)
    with open(path) as handle:
        return strip(handle.read())


def read_raw(rel):
    path = os.path.join(APP, rel)
    if not os.path.isfile(path):
        fail("missing file " + rel)
    with open(path) as handle:
        return handle.read()


def src_files(rel=SRC):
    found = []
    for root, _dirs, files in os.walk(os.path.join(APP, rel)):
        for name in files:
            if name.endswith((".ts", ".tsx")):
                found.append(os.path.relpath(os.path.join(root, name), APP))
    return sorted(found)


def imports(text):
    """Return a list of (names, module) for every import statement."""
    result = []
    for match in re.finditer(r"import\s+([^;]*?)\s+from\s+['\"]([^'\"]+)['\"]", text, flags=re.S):
        result.append((match.group(1), match.group(2)))
    for match in re.finditer(r"import\s+['\"]([^'\"]+)['\"]", text):
        result.append(("", match.group(1)))
    return result


def imported_from(text, name, modules):
    """True when `name` is imported (default or named) from one of `modules`."""
    for names, module in imports(text):
        if module in modules and re.search(r"\b" + re.escape(name) + r"\b", names):
            return True
    return False
text = read(SRC + "/components/ScoutPanel.tsx")
if not re.search(r"makeStyles\(\s*\(?theme\)?\s*=>", text):
    fail("makeStyles in ScoutPanel.tsx must take a theme callback")
if "theme.palette." not in text:
    fail("ScoutPanel.tsx does not read a colour from theme.palette")
if "theme.spacing(" not in text:
    fail("ScoutPanel.tsx does not use theme.spacing(")
if re.search(r"padding\s*:\s*['\"]?\d+px", text) or re.search(r"(padding|marginBottom)\s*:\s*\d+\s*[,}]", text):
    fail("ScoutPanel.tsx still has a fixed pixel padding or margin")
ok("ScoutPanel.tsx takes colours and spacing from the theme")
PY
exit $?
