#!/usr/bin/env bash
# Check: fleet-policy policy denies entity deletion for non-administrators.
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
text = read("plugins/permission-backend-module-fleet-policy/src/policy.ts")
checks = [
  (r"isPermission\(\s*request\.permission\s*,\s*catalogEntityDeletePermission\s*\)", "compare the request with catalogEntityDeletePermission using isPermission"),
  (r"group:default/starfleet-admins", "check the ownership reference group:default/starfleet-admins"),
  (r"return\s*\{\s*result:\s*AuthorizeResult\.DENY\s*\}", "return { result: AuthorizeResult.DENY }"),
  (r"@backstage/plugin-catalog-common/alpha", "import catalogEntityDeletePermission from @backstage/plugin-catalog-common/alpha"),
]
for pattern, message in checks:
    if not re.search(pattern, text):
        print("FAIL: the policy must " + message)
        sys.exit(1)
if re.search(r"return\s+AuthorizeResult", text):
    print("FAIL: a decision is an object, return { result: ... }")
    sys.exit(1)
print("OK: the policy denies deletion by default")
PYEOF

