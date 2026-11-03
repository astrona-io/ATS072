#!/usr/bin/env bash
set -u

python3 - <<'PY'
import os, re, sys
APP = os.environ.get("APP", "/home/candidate/backstage-app")

def fail(message):
    print("FAIL: " + message)
    sys.exit(1)

def load(rel):
    path = os.path.join(APP, rel)
    if not os.path.isfile(path):
        fail("missing file " + rel)
    text = open(path).read()
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)
    text = re.sub(r"(?m)(^|\s)//.*$", "", text)
    return text

def need(pattern, text, message, flags=re.S):
    if not re.search(pattern, text, flags):
        fail(message)
    return re.search(pattern, text, flags)

def reject(pattern, text, message, flags=re.S):
    if re.search(pattern, text, flags):
        fail(message)

app = load("packages/app/src/App.tsx")
need(r"import\s*\{[^}]*\bFleetPage\b[^}]*\}\s*from\s*'@internal/plugin-scout-status'", app,
     "App.tsx does not import FleetPage from '@internal/plugin-scout-status'")
routes = need(r"<FlatRoutes>(.*?)</FlatRoutes>", app, "App.tsx has no FlatRoutes block").group(1)
need(r'<Route\s+path="/fleet"\s+element=\{\s*<FleetPage\s*/>\s*\}\s*/>', routes,
     'No <Route path="/fleet" element={<FleetPage />} /> inside FlatRoutes')
need(r'<Route\s+path="/catalog"', routes, "The existing catalog route was removed")
print("OK: App.tsx imports FleetPage and routes /fleet to it inside FlatRoutes")
PY
