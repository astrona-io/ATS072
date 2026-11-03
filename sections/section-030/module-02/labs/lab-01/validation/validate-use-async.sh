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

card = load("plugins/scout-status/src/components/OutpostStatusCard/OutpostStatusCard.tsx")
need(r"import\s+(?:\{\s*useAsync\s*\}|useAsync)\s+from\s+'react-use(?:/lib/useAsync)?'", card, "Import useAsync from 'react-use'")
need(r"const\s*\{[^}]*\bloading\b[^}]*\}\s*=\s*useAsync\(", card, "Destructure loading from useAsync")
need(r"const\s*\{[^}]*\berror\b[^}]*\}\s*=\s*useAsync\(", card, "Destructure error from useAsync")
match = need(r"useAsync\(\s*async\s*\(\)\s*=>\s*\{(.*?)\}\s*,\s*\[([^\]]*)\]\s*\)", card, "useAsync needs an async callback and a dependency array")
need(r"\bawait\s+catalogApi\.getEntities\(", match.group(1), "getEntities must be awaited inside the useAsync callback")
need(r"\bfilter\s*:", match.group(1), "Pass a filter to getEntities")
if "catalogApi" not in match.group(2):
    fail("the useAsync dependency array must contain catalogApi")
print("OK: getEntities runs inside useAsync with a filter and catalogApi as dependency")
PY
