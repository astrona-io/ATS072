#!/usr/bin/env bash
set -u

python3 - <<'PY'
import os, re, sys
APP = os.environ.get("APP", "/home/candidate/backstage-app")

def fail(message):
    print("FAIL: " + message)
    sys.exit(1)

def load(rel):
    path = os.path.join(APP, rel)
    if not os.path.isfile(path):
        fail("missing file " + rel)
    text = open(path).read()
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"(?m)(^|\s)//.*$", "", text)
    return text

def need(pattern, text, message, flags=re.S):
    if not re.search(pattern, text, flags):
        fail(message)
    return re.search(pattern, text, flags)

def reject(pattern, text, message, flags=re.S):
    if re.search(pattern, text, flags):
        fail(message)

row = load("plugins/scout-status/src/components/FleetRow/FleetRow.tsx")
panel = load("plugins/scout-status/src/components/FleetPanel/FleetPanel.tsx")
need(r"interface\s+FleetRowProps\s*\{[^}]*\bowner\s*\?\s*:\s*string", row, "FleetRowProps needs owner?: string")
need(r"\bowner\s*\?\?\s*'[^']+'", row, "Render owner ?? 'Owner not recorded' for a missing owner")
reject(r"\bowner\s*!|\.toUpperCase\(", row, "FleetRow must not assume owner is present")
reject(r"\bas\s+string\b|\bowner\s*!|spec\?*\.owner\s*!", panel, "FleetPanel must not assert the owner type")
need(r"owner=\{", panel, "FleetPanel must still pass the owner prop")
print("OK: owner is optional end to end")
PY
