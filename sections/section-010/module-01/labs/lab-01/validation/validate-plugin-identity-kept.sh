#!/usr/bin/env bash
# The plugin keeps its id and its root route, and the catalog route stays
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


plugin = need("plugins/scout-status/src/plugin.ts")
if not re.search(r"id:\s*'scout-status'", plugin):
    fail("createPlugin must keep id: 'scout-status'")
if not re.search(r"root:\s*rootRouteRef", plugin):
    fail("createPlugin must keep routes: { root: rootRouteRef }")
app = need("packages/app/src/App.tsx")
if not re.search(r"<Route\s+path=\"/catalog\"", app):
    fail("the /catalog route was removed from App.tsx")
ok("plugin id, root route and catalog route are intact")
PY
