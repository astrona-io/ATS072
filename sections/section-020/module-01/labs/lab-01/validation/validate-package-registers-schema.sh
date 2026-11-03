#!/usr/bin/env bash
# Check: package.json points to config.d.ts and publishes it.
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
path = os.path.join(app, "plugins/scout-status/package.json")
if not os.path.isfile(path):
    print("FAIL: plugins/scout-status/package.json is missing")
    sys.exit(1)
try:
    data = json.load(open(path))
except ValueError:
    print("FAIL: package.json is not valid JSON")
    sys.exit(1)
if data.get("configSchema") != "config.d.ts":
    print("FAIL: configSchema must be \"config.d.ts\"")
    sys.exit(1)
if "config.d.ts" not in data.get("files", []):
    print("FAIL: files must list config.d.ts")
    sys.exit(1)
print("OK: configSchema and files are set")
PYEOF

