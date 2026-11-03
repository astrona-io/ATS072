#!/usr/bin/env bash
# The module imports the extension point from the public node package
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


text = need("plugins/catalog-backend-module-outpost/src/module.ts")
if re.search(r"@backstage/plugin-catalog-backend/src", text):
    fail("module.ts imports from a private path inside @backstage/plugin-catalog-backend")
if not re.search(r"import\s*\{[^}]*\bcatalogProcessingExtensionPoint\b[^}]*\}\s*from\s*'@backstage/plugin-catalog-node'", text):
    fail("catalogProcessingExtensionPoint is not imported from '@backstage/plugin-catalog-node'")
ok("the extension point comes from @backstage/plugin-catalog-node")
PY
