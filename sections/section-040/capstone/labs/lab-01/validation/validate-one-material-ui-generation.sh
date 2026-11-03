#!/usr/bin/env bash
# App and plugin use only Material UI v4 and the card uses v4 imports
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
offenders = []
for rel in src_files(PLUGIN + "/src") + src_files("packages/app/src"):
    text = read(rel)
    for _names, module in imports(text):
        if module.startswith("@mui/"):
            offenders.append(rel + " imports " + module)
if offenders:
    fail("; ".join(offenders))
for manifest in (PLUGIN + "/package.json", "packages/app/package.json"):
    if "@mui" in read_raw(manifest):
        fail(manifest + " declares an @mui package")
card = read(SRC + "/components/ScoutStatusCard.tsx")
for name in ("Typography", "Button"):
    if not imported_from(card, name, ["@material-ui/core", "@material-ui/core/" + name]):
        fail("ScoutStatusCard.tsx does not import " + name + " from @material-ui/core")
if not imported_from(card, "makeStyles", ["@material-ui/core", "@material-ui/core/styles"]):
    fail("ScoutStatusCard.tsx does not import makeStyles from @material-ui/core/styles")
ok("the application and the plugin use one Material UI generation (v4)")
PY
exit $?
