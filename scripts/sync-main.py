"""Rebuild layouts/monokai-for-herdr.json from Herdr's own main layout.

    python3 scripts/sync-main.py [tag]

The layout is Herdr's `defaults/layouts/main.json` with two keys added after "type":
the theme and the settings picture. Without a tag it takes the newest release tag of
herdrdev/herdr-app (vX.Y.Z, no pre-releases). It prints the tag it used. The weekly
workflow in .github/workflows/sync-main.yml runs this and opens a PR (or an issue) when the file
changes, so the layout never falls behind the window Herdr ships.
"""
import json
import pathlib
import re
import subprocess
import sys
import urllib.request

REPO = "https://github.com/herdrdev/herdr-app"
RAW = "https://raw.githubusercontent.com/herdrdev/herdr-app/{tag}/defaults/layouts/main.json"
OUT = pathlib.Path(__file__).resolve().parent.parent / "layouts" / "monokai-for-herdr.json"
ADDED = {"theme": "monokai", "preview": "layouts/monokai-for-herdr.svg"}


def latest_tag():
    refs = subprocess.run(
        ["git", "ls-remote", "--tags", "--sort=-v:refname", REPO, "v*"],
        check=True, capture_output=True, text=True).stdout
    for line in refs.splitlines():
        tag = line.split("refs/tags/")[-1]
        if re.fullmatch(r"v\d+\.\d+\.\d+", tag):
            return tag
    sys.exit("No release tag found at " + REPO)


tag = sys.argv[1] if len(sys.argv) > 1 else latest_tag()
with urllib.request.urlopen(RAW.format(tag=tag), timeout=30) as response:
    main = json.load(response)

layout = {}
for key, value in main.items():
    layout[key] = value
    if key == "type":
        layout.update(ADDED)
if "theme" not in layout:
    sys.exit(f"Herdr {tag}'s main.json has no \"type\" at its root; update this script.")

OUT.write_text(json.dumps(layout, indent=2, ensure_ascii=False) + "\n")
print(tag)
