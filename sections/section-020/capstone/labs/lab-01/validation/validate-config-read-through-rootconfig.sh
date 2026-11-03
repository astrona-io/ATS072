#!/usr/bin/env bash
# Check: the backend plugin and the catalog module read configuration through coreServices.rootConfig.
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
plug = read("plugins/probe-report-backend/src/plugin.ts")
if "process.env" in plug:
    print("FAIL: plugin.ts must not read process.env")
    sys.exit(1)
for pattern, message in [
    (r"\w+:\s*coreServices\.rootConfig", "plugin.ts deps must include coreServices.rootConfig"),
    (r"getString\(\s*['\"]probeReport\.apiKey['\"]\s*\)", "plugin.ts must read probeReport.apiKey with getString"),
    (r"getString\(\s*['\"]probeReport\.endpoint['\"]\s*\)", "plugin.ts must read probeReport.endpoint with getString"),
    (r"getOptionalNumber\(\s*['\"]probeReport\.refreshSeconds['\"]\s*\)\s*\?\?\s*\d+", "plugin.ts must read refreshSeconds with getOptionalNumber and a default"),
]:
    if not re.search(pattern, plug):
        print("FAIL: " + message)
        sys.exit(1)
mod = read("plugins/catalog-backend-module-probe/src/module.ts")
if not re.search(r"\w+:\s*coreServices\.rootConfig", mod):
    print("FAIL: module.ts deps must include coreServices.rootConfig")
    sys.exit(1)
if not re.search(r"getOptionalString\(\s*['\"]probeReport\.annotation['\"]\s*\)\s*\?\?\s*['\"][^'\"]+['\"]", mod):
    print("FAIL: module.ts must read probeReport.annotation with getOptionalString and a default")
    sys.exit(1)
print("OK: backend code reads configuration through rootConfig")
PYEOF

