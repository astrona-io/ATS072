#!/usr/bin/env bash
# The backend plugin id is scout-status
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


text = need("plugins/scout-status-backend/src/plugin.ts")
if re.search(r"pluginId:\s*'scout-status-backend'", text):
    fail("pluginId is 'scout-status-backend'; the id must not include the -backend suffix")
if not re.search(r"createBackendPlugin\(\s*\{\s*pluginId:\s*'scout-status'\s*,", text):
    fail("createBackendPlugin must be called with pluginId: 'scout-status'")
ok("pluginId is scout-status")
PY
