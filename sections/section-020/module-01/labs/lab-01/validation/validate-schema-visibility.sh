#!/usr/bin/env bash
# Check: config.d.ts tags apiToken secret and refreshSeconds and title frontend.
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
text = open(os.path.join(app, "plugins/scout-status/config.d.ts")).read() if os.path.isfile(os.path.join(app, "plugins/scout-status/config.d.ts")) else ""
if not text:
    print("FAIL: plugins/scout-status/config.d.ts is missing")
    sys.exit(1)
def tag(key):
    m = re.search(r"/\*\*((?:(?!\*/).)*?)\*/\s*" + key + r"\??:", text, re.S)
    if not m:
        return None
    t = re.search(r"@(?:deep)?[Vv]isibility\s+(\w+)", m.group(1))
    return t.group(1) if t else None
expected = {"apiToken": "secret", "refreshSeconds": "frontend", "title": "frontend"}
for key, want in expected.items():
    got = tag(key)
    if got != want:
        print("FAIL: " + key + " needs @visibility " + want + " (found " + str(got) + ")")
        sys.exit(1)
print("OK: visibility tags are correct")
PYEOF

