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
need(r"import\s*\{[^}]*\bProgress\b[^}]*\}\s*from\s*'@backstage/core-components'", card, "Import Progress from '@backstage/core-components'")
need(r"import\s*\{[^}]*\bResponseErrorPanel\b[^}]*\}\s*from\s*'@backstage/core-components'", card, "Import ResponseErrorPanel from '@backstage/core-components'")
need(r"<Progress\s*/>", card, "Render <Progress /> while loading")
need(r"<ResponseErrorPanel\s+error=\{\s*error\s*\}\s*/>", card, "Render <ResponseErrorPanel error={error} />")
need(r"\bloading\b[^;]*<Progress", card, "<Progress /> must depend on the loading flag")
need(r"\berror\b[^;]*<ResponseErrorPanel", card, "<ResponseErrorPanel /> must depend on the error value")
print("OK: loading and error states are rendered with the Backstage components")
PY
