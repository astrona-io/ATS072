#!/usr/bin/env bash
# Check: the backend plugin reads configuration through coreServices.rootConfig and not process.env.
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
text = read("plugins/scout-status-backend/src/plugin.ts")
if "process.env" in text:
    print("FAIL: the backend plugin must not read process.env")
    sys.exit(1)
if not re.search(r"\w+:\s*coreServices\.rootConfig", text):
    print("FAIL: deps must include coreServices.rootConfig")
    sys.exit(1)
if not re.search(r"getOptionalNumber\(\s*['\"]scoutStatus\.refreshSeconds['\"]\s*\)\s*\?\?\s*\d+", text):
    print("FAIL: read scoutStatus.refreshSeconds with getOptionalNumber and a default after ??")
    sys.exit(1)
if not re.search(r"getString\(\s*['\"]scoutStatus\.apiToken['\"]\s*\)", text):
    print("FAIL: read scoutStatus.apiToken with getString")
    sys.exit(1)
print("OK: the backend reads configuration through rootConfig")
PYEOF

