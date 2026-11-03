#!/usr/bin/env bash
# Every Material UI package imported is declared in the plugin package.json and is v4
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
try:
    package = json.loads(read_raw(PLUGIN + "/package.json"))
except ValueError:
    fail("plugin package.json is not valid JSON")
declared = set(package.get("dependencies", {})) | set(package.get("peerDependencies", {}))
for needed in ("@material-ui/core", "@backstage/core-components"):
    if needed not in declared:
        fail("plugin package.json no longer declares " + needed)
libraries = set()
for rel in src_files():
    for _names, module in imports(read(rel)):
        if module.startswith("@material-ui/") or module.startswith("@mui/"):
            parts = module.split("/")
            libraries.add("/".join(parts[:2]))
for library in sorted(libraries):
    if library not in declared:
        fail(library + " is imported but not declared in package.json")
if any(library.startswith("@mui/") for library in libraries):
    fail("a Material UI v5 package is still imported")
ok("every Material UI package imported is declared, all from the v4 generation")
PY
exit $?
