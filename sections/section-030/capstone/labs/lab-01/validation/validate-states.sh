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
need(r"const\s*\{[^}]*\bloading\b[^}]*\}\s*=\s*useAsync\(", panel, "Destructure loading from useAsync")
need(r"const\s*\{[^}]*\berror\b[^}]*\}\s*=\s*useAsync\(", panel, "Destructure error from useAsync")
need(r"import\s*\{[^}]*\bProgress\b[^}]*\}\s*from\s*'@backstage/core-components'", panel, "Import Progress from '@backstage/core-components'")
need(r"import\s*\{[^}]*\bResponseErrorPanel\b[^}]*\}\s*from\s*'@backstage/core-components'", panel, "Import ResponseErrorPanel from '@backstage/core-components'")
need(r"\bloading\b[^;]*<Progress\s*/>", panel, "Render <Progress /> when loading is true")
need(r"\berror\b[^;]*<ResponseErrorPanel\s+error=\{\s*error\s*\}\s*/>", panel, "Render <ResponseErrorPanel error={error} /> when error is set")
print("OK: loading and error states are rendered")
PY
