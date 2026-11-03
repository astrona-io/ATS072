#!/usr/bin/env bash
# ScoutList uses Grid container spacing={3} with xs={12} items and each scout is an InfoCard
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
grid = read(SRC + "/components/ScoutList.tsx")
if not imported_from(grid, "Grid", ["@material-ui/core", "@material-ui/core/Grid"]):
    fail("ScoutList.tsx does not import Grid from @material-ui/core")
if not re.search(r"<Grid\b[^>]*\bcontainer\b[^>]*\bspacing=\{3\}", grid):
    fail("ScoutList.tsx needs <Grid container spacing={3}>")
if not re.search(r"<Grid\b[^>]*\bitem\b[^>]*\bxs=\{12\}", grid) or re.search(r"\bsx=", grid):
    fail("ScoutList.tsx needs <Grid item xs={12}> items and no sx prop")
card = read(SRC + "/components/ScoutStatusCard.tsx")
if not imported_from(card, "InfoCard", ["@backstage/core-components"]) or "<InfoCard" not in card:
    fail("ScoutStatusCard.tsx must use InfoCard from @backstage/core-components")
ok("the list uses Grid and each scout renders in an InfoCard")
PY
exit $?
