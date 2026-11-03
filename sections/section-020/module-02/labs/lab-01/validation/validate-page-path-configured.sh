#!/usr/bin/env bash
# Check: app.extensions moves page:scout-status to /fleet-status.
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
text = read("app-config.yaml", "#")
pattern = r"^\s*-\s+page:scout-status:\s*\n\s+config:\s*\n\s+path:\s*/fleet-status\s*$"
if not re.search(pattern, text, re.M):
    print("FAIL: app.extensions must contain page:scout-status with config path /fleet-status")
    sys.exit(1)
print("OK: the page path is configured")
PYEOF

