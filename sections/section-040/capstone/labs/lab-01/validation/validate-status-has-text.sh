#!/usr/bin/env bash
# Status components carry a text label
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
text = read(SRC + "/components/ScoutStatusBadge.tsx")
for name in ("StatusOK", "StatusWarning", "StatusError"):
    if not imported_from(text, name, ["@backstage/core-components"]):
        fail("ScoutStatusBadge.tsx does not import " + name + " from @backstage/core-components")
    found = re.findall(r"<" + name + r">(.*?)</" + name + r">", text, flags=re.S)
    if not found:
        fail("ScoutStatusBadge.tsx does not render <" + name + ">")
    for children in found:
        literal = re.sub(r"\{[^}]*\}", "", children)
        if not re.search(r"[A-Za-z]{3,}", literal):
            fail("<" + name + "> has no visible words, so the state would rely on colour alone")
ok("StatusOK, StatusWarning and StatusError each carry a text label")
PY
exit $?
