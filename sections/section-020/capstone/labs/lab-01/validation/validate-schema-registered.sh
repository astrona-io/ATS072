#!/usr/bin/env bash
# Check: the schema tags apiKey secret and refreshSeconds frontend, and package.json registers it.
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
sp = os.path.join(app, "plugins/probe-report/config.d.ts")
if not os.path.isfile(sp):
    print("FAIL: plugins/probe-report/config.d.ts is missing")
    sys.exit(1)
text = open(sp).read()
def tag(key):
    m = re.search(r"/\*\*((?:(?!\*/).)*?)\*/\s*" + key + r"\??:", text, re.S)
    if not m:
        return None
    t = re.search(r"@(?:deep)?[Vv]isibility\s+(\w+)", m.group(1))
    return t.group(1) if t else None
for key, want in {"apiKey": "secret", "refreshSeconds": "frontend"}.items():
    if tag(key) != want:
        print("FAIL: " + key + " needs @visibility " + want)
        sys.exit(1)
pp = os.path.join(app, "plugins/probe-report/package.json")
try:
    data = json.load(open(pp))
except (OSError, ValueError):
    print("FAIL: plugins/probe-report/package.json is missing or invalid")
    sys.exit(1)
if data.get("configSchema") != "config.d.ts" or "config.d.ts" not in data.get("files", []):
    print("FAIL: package.json needs configSchema and a files entry for config.d.ts")
    sys.exit(1)
print("OK: schema is tagged and registered")
PYEOF

