#!/usr/bin/env bash
# plugin.ts exports ScoutStatusPage built with createRoutableExtension and the root route
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


text = need("plugins/scout-status/src/plugin.ts")
if not re.search(r"import\s*\{[^}]*\bcreateRoutableExtension\b[^}]*\}\s*from\s*'@backstage/core-plugin-api'", text):
    fail("createRoutableExtension is not imported from '@backstage/core-plugin-api' in plugin.ts")
if not re.search(r"export\s+const\s+ScoutStatusPage\s*=\s*scoutStatusPlugin\s*\.provide\(\s*createRoutableExtension\(", text):
    fail("plugin.ts does not export ScoutStatusPage as scoutStatusPlugin.provide(createRoutableExtension(...))")
if not re.search(r"mountPoint:\s*rootRouteRef\b", text):
    fail("the extension does not use mountPoint: rootRouteRef")
if not re.search(r"import\(\s*'\./components/ScoutStatusPage'\s*\)", text):
    fail("the component is not loaded with import('./components/ScoutStatusPage')")
ok("ScoutStatusPage is a routable extension mounted on rootRouteRef")
PY
