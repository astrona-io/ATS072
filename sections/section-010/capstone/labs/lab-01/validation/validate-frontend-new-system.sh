#!/usr/bin/env bash
# The beacon plugin uses createFrontendPlugin and a PageBlueprint page
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


text = read("plugins/beacon/src/plugin.tsx")
if text is None:
    fail("plugins/beacon/src/plugin.tsx is missing (the new frontend system plugin needs JSX, so use the .tsx extension)")
text = code("plugins/beacon/src/plugin.tsx")
if not re.search(r"import\s*\{[^}]*\bcreateFrontendPlugin\b[^}]*\}\s*from\s*'@backstage/frontend-plugin-api'", text):
    fail("createFrontendPlugin is not imported from '@backstage/frontend-plugin-api'")
if not re.search(r"import\s*\{[^}]*\bPageBlueprint\b[^}]*\}\s*from\s*'@backstage/frontend-plugin-api'", text):
    fail("PageBlueprint is not imported from '@backstage/frontend-plugin-api'")
if not re.search(r"PageBlueprint\.make\(\s*\{\s*params:\s*\{[^}]*path:\s*'/beacon'", text, re.S):
    fail("no PageBlueprint.make({ params: { path: '/beacon', ... } })")
if not re.search(r"loader:\s*\(\)\s*=>\s*import\(\s*'\./components/BeaconPage'\s*\)", text):
    fail("the page loader does not use import('./components/BeaconPage')")
if not re.search(r"createFrontendPlugin\(\s*\{\s*pluginId:\s*'beacon'\s*,", text):
    fail("createFrontendPlugin must be called with pluginId: 'beacon'")
if not re.search(r"extensions:\s*\[[^\]]*\]", text):
    fail("createFrontendPlugin has no extensions list")
if "core-plugin-api" in text or re.search(r"\bcreatePlugin\b|createRoutableExtension", text):
    fail("plugin.tsx still uses the legacy createPlugin or createRoutableExtension")
legacy = code("plugins/beacon/src/plugin.ts")
if legacy is not None and re.search(r"\bcreatePlugin\b", legacy):
    fail("the legacy plugins/beacon/src/plugin.ts still exists; remove it")
ok("the beacon plugin is written for the new frontend system")
PY
