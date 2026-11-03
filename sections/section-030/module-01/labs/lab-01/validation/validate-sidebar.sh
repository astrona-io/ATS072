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

root = load("packages/app/src/components/Root/Root.tsx")
need(r'<SidebarItem\s[^>]*?\bto="scout-status"[^>]*/>', root, 'No <SidebarItem ... to="scout-status" /> in Root.tsx')
item = need(r'<SidebarItem\s[^>]*?\bto="scout-status"[^>]*/>', root, "").group(0)
need(r"\bicon=\{\w+\}", item, "The sidebar item has no icon={...}")
need(r'\btext="[^"]+"', item, "The sidebar item has no text")
need(r'<SidebarGroup[^>]*>.*<SidebarItem\s[^>]*?\bto="scout-status".*</SidebarGroup>', root, "The sidebar item is not inside the SidebarGroup")
need(r'<SidebarItem\s[^>]*?\bto="catalog"', root, "The existing catalog sidebar item was removed")
print("OK: Root.tsx has a sidebar item with icon and text that links to scout-status")
PY
