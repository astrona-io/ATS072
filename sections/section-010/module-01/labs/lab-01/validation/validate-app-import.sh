#!/usr/bin/env bash
# App.tsx imports ScoutStatusPage from the plugin package
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
if not re.search(r"import\s*\{[^}]*\bScoutStatusPage\b[^}]*\}\s*from\s*'@internal/plugin-scout-status'\s*;", text):
    fail("App.tsx does not import { ScoutStatusPage } from '@internal/plugin-scout-status'")
ok("App.tsx imports ScoutStatusPage")
PY
