#!/usr/bin/env bash
# ScoutList uses the v4 Grid with container and item and no sx prop
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
text = read(SRC + "/components/ScoutList.tsx")
if not imported_from(text, "Grid", ["@material-ui/core", "@material-ui/core/Grid"]):
    fail("ScoutList.tsx does not import Grid from @material-ui/core")
if not re.search(r"<Grid\b[^>]*\bcontainer\b", text):
    fail("ScoutList.tsx has no <Grid container>")
if not re.search(r"<Grid\b[^>]*\bitem\b[^>]*\bxs=\{?\"?12", text):
    fail("ScoutList.tsx has no <Grid item xs={12}>")
if re.search(r"\bsx=", text):
    fail("ScoutList.tsx uses the sx prop, which exists only in Material UI v5")
ok("ScoutList.tsx lays out cards with the v4 Grid and no sx prop")
PY
exit $?
