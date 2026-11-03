#!/usr/bin/env bash
# Check: the token comes from an environment variable and no literal token is left in the file.
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
if "scout-token-1234" in text:
    print("FAIL: the literal token is still in app-config.yaml")
    sys.exit(1)
if not re.search(r"^\s+apiToken:\s*[\"']?\$\{SCOUT_API_TOKEN\}[\"']?\s*$", text, re.M):
    print("FAIL: scoutStatus.apiToken must be ${SCOUT_API_TOKEN}")
    sys.exit(1)
print("OK: apiToken is read from SCOUT_API_TOKEN")
PYEOF

