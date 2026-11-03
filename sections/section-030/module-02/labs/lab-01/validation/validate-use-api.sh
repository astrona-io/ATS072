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
need(r"import\s*\{[^}]*\buseApi\b[^}]*\}\s*from\s*'@backstage/core-plugin-api'", card, "Import useApi from '@backstage/core-plugin-api'")
need(r"import\s*\{[^}]*\bcatalogApiRef\b[^}]*\}\s*from\s*'@backstage/plugin-catalog-react'", card, "Import catalogApiRef from '@backstage/plugin-catalog-react'")
need(r"=\s*useApi\(\s*catalogApiRef\s*\)", card, "Call useApi(catalogApiRef)")
reject(r"\bfetch\s*\(", card, "Remove the raw fetch call")
print("OK: the card gets the catalog API with useApi(catalogApiRef)")
PY
