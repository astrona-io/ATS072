#!/usr/bin/env bash
# The backend reads the token from configuration, not from source
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
if not re.search(r"\w+:\s*coreServices\.rootConfig", text):
    fail("deps does not contain a coreServices.rootConfig entry")
if not re.search(r"\.getString\(\s*'beacon\.token'\s*\)", text):
    fail("init does not read config.getString('beacon.token')")
if not re.search(r"httpRouter:\s*coreServices\.httpRouter", text) or not re.search(r"httpRouter\.use\(\s*await\s+createRouter\(", text):
    fail("the router must still be mounted with httpRouter.use(await createRouter(...))")
if "lantern-7f3a" in text:
    fail("the token value is still written in plugin.ts")
ok("the token comes from beacon.token in the configuration")
PY
