#!/usr/bin/env bash
# Check: the backend adds both modules with backend.add(import(...)).
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
text = read("packages/backend/src/index.ts")
for pkg in ("@internal/backstage-plugin-catalog-backend-module-scout", "@internal/backstage-plugin-permission-backend-module-fleet-policy", "@backstage/plugin-permission-backend", "@backstage/plugin-catalog-backend"):
    if not re.search(r"^\s*backend\.add\(\s*import\(\s*['\"]" + re.escape(pkg) + r"['\"]\s*\)\s*\)\s*;", text, re.M):
        print("FAIL: backend.add(import('" + pkg + "')) is missing or commented out")
        sys.exit(1)
print("OK: all four backend.add lines are active")
PYEOF

