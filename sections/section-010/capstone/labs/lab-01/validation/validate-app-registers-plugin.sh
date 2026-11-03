#!/usr/bin/env bash
# The app imports the plugin and passes it in features
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
if not re.search(r"import\s*\{[^}]*\bcreateApp\b[^}]*\}\s*from\s*'@backstage/frontend-defaults'", text):
    fail("createApp must still come from '@backstage/frontend-defaults'")
if not re.search(r"import\s+beaconPlugin\s+from\s+'@internal/plugin-beacon'\s*;", text):
    fail("App.tsx does not import the default export: import beaconPlugin from '@internal/plugin-beacon'")
if not re.search(r"features:\s*\[[^\]]*\bbeaconPlugin\b[^\]]*\]", text):
    fail("beaconPlugin is not in the features array of createApp")
data = json.loads(read("packages/app/package.json") or "{}")
if not str(data.get("dependencies", {}).get("@internal/plugin-beacon", "")).startswith("workspace:"):
    fail("packages/app/package.json does not depend on @internal/plugin-beacon with a workspace version")
ok("the app imports and registers the beacon plugin")
PY
