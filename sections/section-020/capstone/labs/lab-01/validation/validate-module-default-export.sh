#!/usr/bin/env bash
# Check: the probe module package exports the module as default.
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
text = read("plugins/catalog-backend-module-probe/src/index.ts")
if not re.search(r"export\s*\{\s*catalogModuleProbeProcessor\s+as\s+default\s*\}\s*from\s*['\"]\./module['\"]", text):
    print("FAIL: src/index.ts must export catalogModuleProbeProcessor as default")
    sys.exit(1)
print("OK: default export present")
PYEOF

