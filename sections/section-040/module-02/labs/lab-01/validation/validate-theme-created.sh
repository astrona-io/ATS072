#!/usr/bin/env bash
# scoutTheme is created with createUnifiedTheme from the light palettes
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
text = read("packages/app/src/theme/scoutTheme.ts")
if not imported_from(text, "createUnifiedTheme", ["@backstage/theme"]):
    fail("scoutTheme.ts does not import createUnifiedTheme from @backstage/theme")
if not imported_from(text, "palettes", ["@backstage/theme"]):
    fail("scoutTheme.ts does not import palettes from @backstage/theme")
if not re.search(r"export\s+const\s+scoutTheme\s*=\s*createUnifiedTheme\(", text):
    fail("scoutTheme.ts does not export scoutTheme = createUnifiedTheme(...)")
if not re.search(r"\.\.\.\s*palettes\.light", text):
    fail("the palette does not start from ...palettes.light")
if not re.search(r"primary\s*:\s*\{\s*main\s*:\s*['\"]#1f6feb['\"]", text, flags=re.I):
    fail("the primary colour main is not #1f6feb")
if not re.search(r"defaultPageTheme\s*:\s*['\"]home['\"]", text):
    fail("defaultPageTheme is not 'home'")
ok("scoutTheme is created with createUnifiedTheme from the light palettes")
PY
exit $?
