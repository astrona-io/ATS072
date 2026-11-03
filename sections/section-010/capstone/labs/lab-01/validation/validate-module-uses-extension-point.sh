#!/usr/bin/env bash
# The ground-station module adds its source through the extension point
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


text = need("plugins/beacon-backend-module-ground-station/src/module.ts")
if not re.search(r"createBackendModule\(\s*\{\s*pluginId:\s*'beacon'\s*,\s*moduleId:\s*'ground-station'\s*,", text):
    fail("createBackendModule must keep pluginId 'beacon' and moduleId 'ground-station'")
if not re.search(r"import\s*\{[^}]*\bbeaconSourcesExtensionPoint\b[^}]*\}\s*from\s*'@internal/plugin-beacon-node'", text):
    fail("beaconSourcesExtensionPoint is not imported from '@internal/plugin-beacon-node'")
if not re.search(r"import\s*\{[^}]*\bgroundStationSource\b[^}]*\}\s*from\s*'\./sources'", text):
    fail("groundStationSource is not imported from './sources'")
if not re.search(r"\b(\w+):\s*beaconSourcesExtensionPoint\b", text):
    fail("deps does not contain an entry for beaconSourcesExtensionPoint")
dep = re.search(r"\b(\w+):\s*beaconSourcesExtensionPoint\b", text).group(1)
if not re.search(r"\b" + dep + r"\.addSource\(\s*groundStationSource\s*\)", text):
    fail("init does not call " + dep + ".addSource(groundStationSource)")
ok("the module registers groundStationSource")
PY
