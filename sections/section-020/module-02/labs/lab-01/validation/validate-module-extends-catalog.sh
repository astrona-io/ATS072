#!/usr/bin/env bash
# Check: the scout module extends the catalog and adds its processor.
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
text = read("plugins/catalog-backend-module-scout/src/module.ts")
if not re.search(r"createBackendModule\(", text):
    print("FAIL: module.ts must call createBackendModule")
    sys.exit(1)
if not re.search(r"pluginId:\s*['\"]catalog['\"]", text):
    print("FAIL: pluginId must be 'catalog'")
    sys.exit(1)
if not re.search(r"\w+:\s*catalogProcessingExtensionPoint", text) or "@backstage/plugin-catalog-node" not in text:
    print("FAIL: deps must contain catalogProcessingExtensionPoint from @backstage/plugin-catalog-node")
    sys.exit(1)
if not re.search(r"\.addProcessor\(\s*new\s+ScoutProcessor\(", text):
    print("FAIL: init must call addProcessor(new ScoutProcessor(...))")
    sys.exit(1)
print("OK: the module adds ScoutProcessor to the catalog")
PYEOF

