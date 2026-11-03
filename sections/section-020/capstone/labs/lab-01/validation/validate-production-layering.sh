#!/usr/bin/env bash
# Check: the production file only overrides refreshSeconds and the start script loads both files in order.
set -u

APP=/home/candidate/backstage-app

python3 - "$APP" <<'PYEOF'
import json, os, re, sys
app = sys.argv[1]

def read(path, comment="//"):
    full = os.path.join(app, path)
    if not os.path.isfile(full):
        print("FAIL: missing file " + path)
        sys.exit(1)
    lines = []
    for line in open(full).read().splitlines():
        if line.strip().startswith(comment):
            continue
        lines.append(line)
    return "\n".join(lines)
prod = read("app-config.production.yaml", "#")
if "apiKey" in prod or "probe-key" in prod:
    print("FAIL: the production file must not repeat the key")
    sys.exit(1)
if not re.search(r"refreshSeconds:\s*120", prod):
    print("FAIL: the production file must set refreshSeconds: 120")
    sys.exit(1)
path = os.path.join(app, "packages/backend/package.json")
try:
    scripts = json.load(open(path)).get("scripts", {})
except (OSError, ValueError):
    print("FAIL: packages/backend/package.json is missing or invalid")
    sys.exit(1)
cmd = scripts.get("start:production", "")
if not re.search(r"--config\s+\S*app-config\.yaml\s+--config\s+\S*app-config\.production\.yaml", cmd):
    print("FAIL: start:production must load app-config.yaml and then app-config.production.yaml")
    sys.exit(1)
print("OK: layering is correct")
PYEOF

