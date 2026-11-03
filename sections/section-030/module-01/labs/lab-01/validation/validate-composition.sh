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

page = load("plugins/scout-status/src/components/ScoutStatusPage/ScoutStatusPage.tsx")
need(r'<OutpostCard\s[^>]*\bname="[^"]+"', page, "OutpostCard gets no name prop")
need(r"<OutpostCard\s[^>]*\bcrew=\{\d+\}", page, "OutpostCard gets no crew={number} prop")
need(r'<CrewCounter\s[^>]*\boutpost="[^"]+"', page, "CrewCounter gets no outpost prop")
print("OK: ScoutStatusPage passes props to both components")
PY
