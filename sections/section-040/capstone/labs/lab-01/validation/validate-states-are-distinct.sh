#!/usr/bin/env bash
# Loading, error and empty states render Progress, ResponseErrorPanel and EmptyState
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
text = read(SRC + "/components/ScoutStatusPage.tsx")
for name in ("Progress", "ResponseErrorPanel", "EmptyState"):
    if not imported_from(text, name, ["@backstage/core-components"]):
        fail("ScoutStatusPage.tsx does not import " + name + " from @backstage/core-components")
if "<Progress" not in text:
    fail("no <Progress> for the loading state")
if not re.search(r"<ResponseErrorPanel\s+error=\{error\}", text):
    fail("no <ResponseErrorPanel error={error}> for the error state")
empty = re.search(r"<EmptyState\b(?:[^>{]|\{[^}]*\})*>", text, flags=re.S)
if not empty or "title=" not in empty.group(0) or "description=" not in empty.group(0):
    fail("no <EmptyState> with a title and a description for the empty state")
if re.search(r"if\s*\(\s*loading\s*\)\s*\{?\s*return\s+null", text):
    fail("the loading state still returns null")
order = [text.find("if (loading)"), text.find("(error)"), text.find(".length")]
if min(order) < 0 or not (order[0] < order[1] < order[2]):
    fail("check loading first, then error, then an empty list")
ok("loading, error and empty states each render their own component")
PY
exit $?
