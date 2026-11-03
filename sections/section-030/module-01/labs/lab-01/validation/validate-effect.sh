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

counter = load("plugins/scout-status/src/components/CrewCounter/CrewCounter.tsx")
need(r"useState\(", counter, "CrewCounter must keep the count with useState")
match = need(r"useEffect\(\s*\(\)\s*=>\s*\{.*?\}\s*,\s*\[([^\]]*)\]\s*\)", counter, "useEffect has no dependency array")
deps = [d.strip() for d in match.group(1).split(",") if d.strip()]
if "outpost" not in deps or "count" not in deps:
    fail("the dependency array must contain outpost and count, found [" + ", ".join(deps) + "]")
need(r"document\.title\s*=", counter, "The effect must still set document.title")
print("OK: useEffect depends on outpost and count")
PY
