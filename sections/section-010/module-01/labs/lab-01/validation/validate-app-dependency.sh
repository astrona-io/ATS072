#!/usr/bin/env bash
# The app package lists the plugin package as a dependency
set -u

APP="${BACKSTAGE_APP:-/home/candidate/backstage-app}"

python3 - "$APP" <<'PY'
import json, os, re, sys

app = sys.argv[1]


def read(rel):
    try:
        with open(os.path.join(app, rel), encoding="utf-8") as handle:
            return handle.read()
    except OSError:
        return None


def code(rel):
    text = read(rel)
    if text is None:
        return None
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"(?m)^\s*//.*$", "", text)
    text = re.sub(r"(?m)[ \t]//[ \t].*$", "", text)
    return text


def fail(message):
    print("FAIL: " + message)
    sys.exit(1)


def ok(message):
    print("OK: " + message)
    sys.exit(0)


def need(rel):
    text = code(rel)
    if text is None:
        fail(rel + " is missing")
    return text


text = read("packages/app/package.json")
if text is None:
    fail("packages/app/package.json is missing")
try:
    data = json.loads(text)
except ValueError:
    fail("packages/app/package.json is not valid JSON")
value = data.get("dependencies", {}).get("@internal/plugin-scout-status")
if not value:
    fail("@internal/plugin-scout-status is not in the dependencies of packages/app/package.json")
if not (value.startswith("workspace:") or value.startswith("link:")):
    fail("the dependency must point at the workspace package (workspace:^), found " + value)
ok("the app depends on @internal/plugin-scout-status (" + value + ")")
PY
