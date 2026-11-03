#!/usr/bin/env bash
# The plugin package entry point default-exports the plugin
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


text = need("plugins/beacon/src/index.ts")
if not re.search(r"export\s*\{\s*beaconPlugin\s+as\s+default\s*\}\s*from\s*'\./plugin'", text):
    fail("index.ts must contain export { beaconPlugin as default } from './plugin'")
ok("beaconPlugin is the default export of the package")
PY
