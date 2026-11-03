#!/usr/bin/env bash
# Check: the card does not read the secret key.
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
text = read("plugins/probe-report/src/components/ProbeReportCard.tsx")
if "apiKey" in text:
    print("FAIL: the card must not read probeReport.apiKey")
    sys.exit(1)
if "useApi(configApiRef)" not in text:
    print("FAIL: the card must read configuration with useApi(configApiRef)")
    sys.exit(1)
print("OK: the card reads only frontend settings")
PYEOF

