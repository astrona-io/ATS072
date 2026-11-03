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
need(r"\.length\s*===\s*0", card, "Handle an empty list with a length === 0 check")
need(r"<p>[^<]*No outposts[^<]*</p>", card, "Show a <p> message that starts the empty state with No outposts")
keys = re.findall(r"\bkey=\{([^}]*(?:\{[^}]*\}[^}]*)*)\}", card)
if not keys:
    fail("list items need a key")
for key in keys:
    if re.search(r"\bindex\b|\bidx\b|\bi\b", key):
        fail("a key uses the list position: key={" + key + "}")
if not any("stringifyEntityRef(" in k or "metadata.uid" in k for k in keys):
    fail("use stringifyEntityRef(entity) or metadata.uid as the key")
reject(r"\.map\(\s*\(?\s*\w+\s*,\s*\w+", card, "The map callback must not take an index argument")
if "stringifyEntityRef(" in card:
    need(r"import\s*\{[^}]*\bstringifyEntityRef\b[^}]*\}\s*from\s*'@backstage/catalog-model'", card, "Import stringifyEntityRef from '@backstage/catalog-model'")
print("OK: empty state present and keys come from the entity identity")
PY
