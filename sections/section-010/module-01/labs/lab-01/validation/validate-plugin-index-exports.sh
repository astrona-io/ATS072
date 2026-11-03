#!/usr/bin/env bash
# The plugin package entry point exports the plugin and the page
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


text = need("plugins/scout-status/src/index.ts")
match = re.search(r"export\s*\{([^}]*)\}\s*from\s*'\./plugin'", text)
if not match:
    fail("index.ts has no export { ... } from './plugin'")
names = [n.strip() for n in match.group(1).split(",") if n.strip()]
for wanted in ("scoutStatusPlugin", "ScoutStatusPage"):
    if wanted not in names:
        fail(wanted + " is not exported from index.ts")
ok("index.ts exports scoutStatusPlugin and ScoutStatusPage")
PY
