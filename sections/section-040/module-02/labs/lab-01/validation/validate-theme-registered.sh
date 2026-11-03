#!/usr/bin/env bash
# App.tsx registers scoutTheme through UnifiedThemeProvider in createApp
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
text = read("packages/app/src/App.tsx")
if not imported_from(text, "UnifiedThemeProvider", ["@backstage/theme"]):
    fail("App.tsx does not import UnifiedThemeProvider from @backstage/theme")
if not imported_from(text, "scoutTheme", ["./theme/scoutTheme"]):
    fail("App.tsx does not import scoutTheme from ./theme/scoutTheme")
call = re.search(r"createApp\(\{(.*)\}\)\s*;", text, flags=re.S)
if not call or "themes" not in call.group(1):
    fail("createApp has no themes option")
body = call.group(1)
if not re.search(r"\bid\s*:\s*['\"][^'\"]+['\"]", body) or not re.search(r"\btitle\s*:\s*['\"][^'\"]+['\"]", body):
    fail("the theme entry needs an id and a title")
if not re.search(r"variant\s*:\s*['\"]light['\"]", body):
    fail("the theme entry needs variant: 'light'")
if not re.search(r"<UnifiedThemeProvider\s+theme=\{scoutTheme\}", body):
    fail("Provider must render <UnifiedThemeProvider theme={scoutTheme} ...>")
ok("App.tsx registers scoutTheme through UnifiedThemeProvider")
PY
exit $?
