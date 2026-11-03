#!/usr/bin/env bash
# The plugin depends on httpRouter and mounts the router in init
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
if not re.search(r"httpRouter:\s*coreServices\.httpRouter", text):
    fail("deps does not contain httpRouter: coreServices.httpRouter")
if not re.search(r"async\s+init\(\s*\{[^}]*\bhttpRouter\b[^}]*\}\s*\)", text):
    fail("init does not receive httpRouter")
if not re.search(r"httpRouter\.use\(\s*await\s+createRouter\(\s*\{[^}]*\blogger\b[^}]*\}\s*\)\s*\)", text):
    fail("init does not call httpRouter.use(await createRouter({ logger }))")
ok("the router is created and mounted with httpRouter")
PY
