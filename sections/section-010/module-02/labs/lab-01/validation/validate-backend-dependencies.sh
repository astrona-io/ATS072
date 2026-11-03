#!/usr/bin/env bash
# The backend package lists both internal packages
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


text = read("packages/backend/package.json")
if text is None:
    fail("packages/backend/package.json is missing")
try:
    data = json.loads(text)
except ValueError:
    fail("packages/backend/package.json is not valid JSON")
deps = data.get("dependencies", {})
for name in ("@internal/plugin-scout-status-backend", "@internal/plugin-catalog-backend-module-outpost"):
    value = deps.get(name, "")
    if not value.startswith("workspace:"):
        fail(name + " is not a workspace dependency of packages/backend")
ok("both internal packages are workspace dependencies of the backend")
PY
