#!/usr/bin/env bash
# The backend adds the beacon plugin and the module but not the node library
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


text = need("packages/backend/src/index.ts")
for name in ("@internal/plugin-beacon-backend", "@internal/plugin-beacon-backend-module-ground-station"):
    pattern = r"^\s*backend\.add\(\s*import\(\s*'" + re.escape(name) + r"'\s*\)\s*\)\s*;"
    if not re.search(pattern, text, re.M):
        fail("index.ts has no active backend.add(import('" + name + "'));")
if "plugin-beacon-node" in text:
    fail("the node library @internal/plugin-beacon-node is not a plugin or module and must not be added")
if not re.search(r"^\s*backend\.add\(\s*import\(\s*'@backstage/plugin-app-backend'\s*\)\s*\)\s*;", text, re.M):
    fail("the app backend plugin is no longer added")
ok("the backend adds the beacon plugin and the ground-station module")
PY
