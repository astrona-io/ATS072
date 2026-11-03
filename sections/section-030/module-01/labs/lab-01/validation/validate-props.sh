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

card = load("plugins/scout-status/src/components/OutpostCard/OutpostCard.tsx")
need(r"interface\s+OutpostCardProps\s*\{[^}]*\bname\s*:\s*string", card, "OutpostCardProps needs name: string")
need(r"interface\s+OutpostCardProps\s*\{[^}]*\bcrew\s*\?\s*:\s*number", card, "OutpostCardProps needs an optional crew?: number")
need(r"OutpostCard\s*=\s*\(\s*\{[^}]*\bname\b[^}]*\bcrew\b[^}]*\}\s*:\s*OutpostCardProps", card, "OutpostCard must destructure name and crew from OutpostCardProps")
need(r"<h3>\s*\{\s*name\s*\}\s*</h3>", card, "OutpostCard must render {name}")
need(r"Crew not recorded", card, "OutpostCard needs an explicit text for a missing crew value")
reject(r"outpost-alpha", card, "OutpostCard still contains the fixed outpost name")
reject(r"\bcrew\s*!|\bcrew\s+as\s+number", card, "Do not assert that crew is always present")
print("OK: OutpostCard has typed props and an explicit missing-crew text")
PY
