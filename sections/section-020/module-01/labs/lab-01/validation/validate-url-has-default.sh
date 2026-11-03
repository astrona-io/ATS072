#!/usr/bin/env bash
# Check: the API URL uses substitution with a default value.
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
if not re.search(r"^\s+apiUrl:\s*[\"']?\$\{SCOUT_API_URL:-http://[^}]+\}[\"']?\s*$", text, re.M):
    print("FAIL: scoutStatus.apiUrl must be ${SCOUT_API_URL:-<default http URL>}")
    sys.exit(1)
print("OK: apiUrl uses ${SCOUT_API_URL:-default}")
PYEOF

