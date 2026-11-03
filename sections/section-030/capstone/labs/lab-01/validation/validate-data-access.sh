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
need(r"import\s*\{[^}]*\buseApi\b[^}]*\}\s*from\s*'@backstage/core-plugin-api'", panel, "Import useApi from '@backstage/core-plugin-api'")
need(r"import\s*\{[^}]*\bcatalogApiRef\b[^}]*\}\s*from\s*'@backstage/plugin-catalog-react'", panel, "Import catalogApiRef from '@backstage/plugin-catalog-react'")
need(r"=\s*useApi\(\s*catalogApiRef\s*\)", panel, "Call useApi(catalogApiRef)")
reject(r"\bfetch\s*\(", panel, "Remove the raw fetch call")
need(r"import\s+(?:\{\s*useAsync\s*\}|useAsync)\s+from\s+'react-use(?:/lib/useAsync)?'", panel, "Import useAsync from 'react-use'")
match = need(r"useAsync\(\s*async\s*\(\)\s*=>\s*\{(.*?)\}\s*,\s*\[([^\]]*)\]\s*\)", panel, "useAsync needs an async callback and a dependency array")
need(r"\bawait\s+catalogApi\.getEntities\(", match.group(1), "getEntities must be awaited inside useAsync")
if "catalogApi" not in match.group(2):
    fail("the useAsync dependency array must contain catalogApi")
print("OK: catalog data comes from useApi(catalogApiRef) inside useAsync")
PY
