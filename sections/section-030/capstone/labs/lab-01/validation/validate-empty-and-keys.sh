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

panel = load("plugins/scout-status/src/components/FleetPanel/FleetPanel.tsx")
need(r"\.length\s*===\s*0", panel, "Handle an empty list with a length === 0 check")
need(r"<p>[^<]*No ships[^<]*</p>", panel, "Show a <p> empty-state message that starts with No ships")
keys = re.findall(r"\bkey=\{([^}]*(?:\{[^}]*\}[^}]*)*)\}", panel)
if not keys:
    fail("FleetRow elements need a key")
for key in keys:
    if re.search(r"\bindex\b|\bidx\b|\bi\b", key):
        fail("a key uses the list position: key={" + key + "}")
if not any("stringifyEntityRef(" in k or "metadata.uid" in k for k in keys):
    fail("use stringifyEntityRef(entity) or metadata.uid as the key")
reject(r"\.map\(\s*\(?\s*\w+\s*,\s*\w+", panel, "The map callback must not take an index argument")
print("OK: empty state present and keys come from the entity identity")
PY
