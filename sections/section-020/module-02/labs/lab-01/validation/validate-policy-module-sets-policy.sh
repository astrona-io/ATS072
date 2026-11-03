#!/usr/bin/env bash
# Check: the permission module registers the policy through policyExtensionPoint.
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
text = read("plugins/permission-backend-module-fleet-policy/src/module.ts")
if not re.search(r"pluginId:\s*['\"]permission['\"]", text):
    print("FAIL: pluginId must be 'permission'")
    sys.exit(1)
if not re.search(r"policy:\s*policyExtensionPoint", text):
    print("FAIL: deps must contain policy: policyExtensionPoint")
    sys.exit(1)
if not re.search(r"policy\.setPolicy\(\s*new\s+FleetPolicy\(\s*\)\s*\)", text):
    print("FAIL: init must call policy.setPolicy(new FleetPolicy())")
    sys.exit(1)
print("OK: the policy is registered")
PYEOF

