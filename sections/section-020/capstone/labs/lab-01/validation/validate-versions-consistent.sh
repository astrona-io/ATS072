#!/usr/bin/env bash
# Check: every package.json asks for the same version of each @backstage package.
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
seen = {}
for base in ("plugins", "packages"):
    for dirpath, dirs, files in os.walk(os.path.join(app, base)):
        if "package.json" in files:
            try:
                data = json.load(open(os.path.join(dirpath, "package.json")))
            except ValueError:
                print("FAIL: invalid JSON in " + dirpath)
                sys.exit(1)
            for section in ("dependencies", "devDependencies"):
                for name, version in data.get(section, {}).items():
                    if name.startswith("@backstage/"):
                        seen.setdefault(name, set()).add(version)
if not seen:
    print("FAIL: no @backstage dependencies found")
    sys.exit(1)
for name, versions in sorted(seen.items()):
    if len(versions) > 1:
        print("FAIL: " + name + " has several versions: " + ", ".join(sorted(versions)))
        sys.exit(1)
print("OK: one version per @backstage package")
PYEOF

