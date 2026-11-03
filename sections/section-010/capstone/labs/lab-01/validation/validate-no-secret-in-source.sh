#!/usr/bin/env bash
# The token is not in any plugin source file and the browser code sends no Authorization header
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


hits = []
for base, _dirs, names in os.walk(os.path.join(app, "plugins")):
    for name in names:
        if name.endswith((".ts", ".tsx", ".json")):
            path = os.path.join(base, name)
            with open(path, encoding="utf-8") as handle:
                if "lantern-7f3a" in handle.read():
                    hits.append(os.path.relpath(path, app))
if hits:
    fail("the token value is still written in: " + ", ".join(sorted(hits)))
page = need("plugins/beacon/src/components/BeaconPage.tsx")
if re.search(r"Authorization|Bearer", page):
    fail("BeaconPage.tsx still sets an Authorization header; the backend uses the token, not the browser")
if not re.search(r"discoveryApi\.getBaseUrl\(\s*'beacon'\s*\)", page):
    fail("BeaconPage.tsx must still use discoveryApi.getBaseUrl('beacon')")
cfg = read("app-config.yaml") or ""
if not re.search(r"(?m)^\s+token:\s*\$\{BEACON_TOKEN\}\s*$", cfg):
    fail("app-config.yaml must keep token: ${BEACON_TOKEN} under beacon")
ok("the token only lives in configuration and the browser code does not send it")
PY
