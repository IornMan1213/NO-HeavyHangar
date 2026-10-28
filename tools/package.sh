#!/usr/bin/env bash
# Release zip in the layout NOMNOM / NOMM install: build/Heavy-Hangar_<version>.zip with the files at the top level
# (.nobp, plugin, licence, readme), unpacked into BepInEx/plugins/HeavyHangar/. Adds the release's artifact (sha256,
# download URL) to nomnom/HeavyHangar.json. Run tools/build_hangar.sh first, or point HH_BUILD at another build folder
# with the same version (NO-B52's build/ holds the same hangar).
#   bash tools/package.sh          a release        bash tools/package.sh --pre   a GitHub pre-release
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; cd "$ROOT"
B="${HH_BUILD:-$ROOT/build}"
CATEGORY=release; [[ "${1:-}" == --pre ]] && CATEGORY=preRelease
V="$(grep -oE 'BepInPlugin\("[^"]+", "[^"]+", "[0-9.]+"\)' plugin/HeavyHangar/Plugin.cs | grep -oE '"[0-9.]+"\)' | tr -d '")')"
BV="$(grep -oE 'const string Version = "[0-9.]+"' unity/Editor/HangarBuilder.cs | grep -oE '[0-9][0-9.]*')"
PV="$(grep -oE '<Version>[0-9.]+</Version>' plugin/HeavyHangar/HeavyHangar.csproj | grep -oE '[0-9][0-9.]*')"
[[ "$V" == "$BV" && "$V" == "$PV" ]] || { echo "Version mismatch: plugin $V, builder $BV, csproj $PV"; exit 1; }
grep -q "^## $V" CHANGELOG.md || { echo "CHANGELOG.md has no '## $V' section"; exit 1; }
NOBP="$B/Heavy Hangar_$V.nobp"; DLL="$B/plugin/HeavyHangar.dll"
[[ -f "$NOBP" && -f "$DLL" ]] || { echo "Missing $NOBP or $DLL (build first)"; exit 1; }

STAGE="$ROOT/build/package"; rm -rf "$STAGE"; mkdir -p "$STAGE"
cp "$NOBP" "$DLL" "$STAGE/"; cp LICENSE "$STAGE/LICENSE.txt"
sed "s/{VERSION}/$V/g" tools/release_readme.txt > "$STAGE/README.txt"
ZIP="$ROOT/build/Heavy-Hangar_$V.zip"; rm -f "$ZIP"
python3 - "$STAGE" "$ZIP" <<'PY'
import os, sys, zipfile
stage, out = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as z:
    for f in sorted(os.listdir(stage)): z.write(os.path.join(stage, f), f)
PY
SHA="$(sha256sum "$ZIP" | cut -d' ' -f1)"
python3 -c "import zipfile,sys; [print(f'  {i.file_size:>10}  {i.filename}') for i in zipfile.ZipFile(sys.argv[1]).infolist()]" "$ZIP"
echo "sha256: $SHA"
python3 - "$V" "$(basename "$ZIP")" "$SHA" "$CATEGORY" <<'PY'
import json, sys
v, name, sha, cat = sys.argv[1:5]
p = "nomnom/HeavyHangar.json"; m = json.load(open(p, encoding="utf-8"))
a = {"fileName": name, "version": v, "category": cat, "type": "addon", "gameVersion": "0.34.3",
     "downloadUrl": f"https://github.com/{m['githubOwner']}/{m['githubRepoName']}/releases/download/v{v}/{name}",
     "hash": f"sha256:{sha}", "extends": {"id": "com.nikkorap.blueprinter", "version": "2.0.1"}}
m["artifacts"] = [a] + [x for x in m.get("artifacts", []) if x.get("version") != v]
json.dump(m, open(p, "w", encoding="utf-8", newline="\n"), indent=2, ensure_ascii=False); open(p, "a").write("\n")
print(f"NOMNOM manifest: {p} ({cat} {v})")
PY
