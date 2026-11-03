#!/usr/bin/env bash
# backend/src/index.ts adds the outpost catalog module
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
if not re.search(r"^\s*backend\.add\(\s*import\(\s*'@internal/plugin-catalog-backend-module-outpost'\s*\)\s*\)\s*;", text, re.M):
    fail("index.ts has no backend.add(import('@internal/plugin-catalog-backend-module-outpost'));")
if not re.search(r"^\s*backend\.add\(\s*import\(\s*'@backstage/plugin-catalog-backend'\s*\)\s*\)\s*;", text, re.M):
    fail("the catalog backend plugin is no longer added")
ok("the backend adds the outpost module next to the catalog plugin")
PY
