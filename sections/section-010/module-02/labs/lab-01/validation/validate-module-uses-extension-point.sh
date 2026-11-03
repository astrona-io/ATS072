#!/usr/bin/env bash
# The module depends on the extension point and adds the processor
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
if not re.search(r"createBackendModule\(\s*\{\s*pluginId:\s*'catalog'\s*,\s*moduleId:\s*'outpost-entities'\s*,", text):
    fail("createBackendModule must keep pluginId 'catalog' and moduleId 'outpost-entities'")
if not re.search(r"\bcatalog:\s*catalogProcessingExtensionPoint\b", text):
    fail("deps does not contain catalog: catalogProcessingExtensionPoint")
if not re.search(r"async\s+init\(\s*\{[^}]*\bcatalog\b[^}]*\}\s*\)", text):
    fail("init does not receive catalog")
if not re.search(r"\bcatalog\.addProcessor\(\s*new\s+OutpostProcessor\(\s*\)\s*\)", text):
    fail("init does not call catalog.addProcessor(new OutpostProcessor())")
ok("the module registers OutpostProcessor through the catalog extension point")
PY
