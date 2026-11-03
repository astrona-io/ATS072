#!/usr/bin/env bash
# scoutTheme is created with createUnifiedTheme and registered in createApp
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
theme = read("packages/app/src/theme/scoutTheme.ts")
if not re.search(r"export\s+const\s+scoutTheme\s*=\s*createUnifiedTheme\(", theme) or not re.search(r"\.\.\.\s*palettes\.light", theme):
    fail("scoutTheme.ts must export scoutTheme = createUnifiedTheme({ palette: { ...palettes.light, ... } })")
app = read("packages/app/src/App.tsx")
call = re.search(r"createApp\(\{(.*)\}\)\s*;", app, flags=re.S)
if not call or "themes" not in call.group(1):
    fail("createApp has no themes option")
if not re.search(r"variant\s*:\s*['\"]light['\"]", call.group(1)) or not re.search(r"<UnifiedThemeProvider\s+theme=\{scoutTheme\}", call.group(1)):
    fail("the theme entry needs variant: 'light' and a Provider that renders UnifiedThemeProvider with scoutTheme")
ok("scoutTheme is created and registered in createApp")
PY
exit $?
