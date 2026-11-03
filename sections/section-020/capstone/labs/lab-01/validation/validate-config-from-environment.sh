#!/usr/bin/env bash
# Check: endpoint has a default and apiKey comes from the environment.
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
if "probe-key-77" in text:
    print("FAIL: the literal key is still in app-config.yaml")
    sys.exit(1)
if not re.search(r"^\s+apiKey:\s*[\"']?\$\{PROBE_API_KEY\}[\"']?\s*$", text, re.M):
    print("FAIL: probeReport.apiKey must be ${PROBE_API_KEY}")
    sys.exit(1)
if not re.search(r"^\s+endpoint:\s*[\"']?\$\{PROBE_ENDPOINT:-http://[^}]+\}[\"']?\s*$", text, re.M):
    print("FAIL: probeReport.endpoint must be ${PROBE_ENDPOINT:-<default http URL>}")
    sys.exit(1)
print("OK: endpoint and apiKey use substitution")
PYEOF

