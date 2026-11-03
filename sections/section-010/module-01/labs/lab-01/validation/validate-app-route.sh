#!/usr/bin/env bash
# App.tsx mounts ScoutStatusPage at /scout-status inside FlatRoutes
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


text = need("packages/app/src/App.tsx")
block = re.search(r"<FlatRoutes>(.*?)</FlatRoutes>", text, re.S)
if not block:
    fail("App.tsx has no <FlatRoutes> block")
if not re.search(r"<Route\s+path=\"/scout-status\"\s+element=\{\s*<ScoutStatusPage\s*/>\s*\}\s*/>", block.group(1)):
    fail('no <Route path="/scout-status" element={<ScoutStatusPage />} /> inside <FlatRoutes> (comments do not count)')
ok("the /scout-status route is mounted")
PY
