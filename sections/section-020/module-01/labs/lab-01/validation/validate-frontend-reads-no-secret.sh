#!/usr/bin/env bash
# Check: the card uses configApiRef and does not read the secret token.
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
text = read("plugins/scout-status/src/components/ScoutStatusCard.tsx")
if "apiToken" in text:
    print("FAIL: the frontend card must not read scoutStatus.apiToken")
    sys.exit(1)
if "configApiRef" not in text or "useApi(configApiRef)" not in text:
    print("FAIL: the card must read configuration with useApi(configApiRef)")
    sys.exit(1)
print("OK: the card reads only frontend settings")
PYEOF

