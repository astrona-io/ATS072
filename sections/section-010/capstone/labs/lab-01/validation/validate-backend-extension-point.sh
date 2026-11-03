#!/usr/bin/env bash
# The beacon backend plugin registers the extension point
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


text = need("plugins/beacon-backend/src/plugin.ts")
if not re.search(r"createBackendPlugin\(\s*\{\s*pluginId:\s*'beacon'\s*,", text):
    fail("createBackendPlugin must use pluginId: 'beacon'")
if not re.search(r"import\s*\{[^}]*\bbeaconSourcesExtensionPoint\b[^}]*\}\s*from\s*'@internal/plugin-beacon-node'", text):
    fail("beaconSourcesExtensionPoint is not imported from '@internal/plugin-beacon-node'")
reg = re.search(r"env\.registerExtensionPoint\(\s*beaconSourcesExtensionPoint\s*,\s*\{(.*?)\}\s*\)\s*;", text, re.S)
if not reg:
    fail("register does not call env.registerExtensionPoint(beaconSourcesExtensionPoint, { ... })")
if not re.search(r"addSource\(\s*\w+\s*\)\s*\{[^}]*sources\.push\(", reg.group(0) + "}", re.S):
    fail("the extension point implementation must have addSource(source) that pushes into sources")
ok("the plugin registers beaconSourcesExtensionPoint")
PY
