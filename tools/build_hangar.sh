#!/usr/bin/env bash
# Heavy Hangar build: textures -> Blender model -> FBX -> Unity prefab + definition -> .nobp -> plugin, into build/.
# Linux, or Windows with Git Bash. The game must be closed (it and Unity both lock files). Paths: tools/env.sh.
# Needs HH_UNITY_PROJECT: a Blueprinter Editor project (Unity 2022.3.62f2). NO-B52 builds the same hangar with its
# own copy of these files (tools/build_hangar.sh there); keep the two in step.
set -euo pipefail
source "$(dirname "$0")/env.sh"
cd "$ROOT"
[[ -n "${HH_UNITY_PROJECT:-}" && -d "$HH_UNITY_PROJECT/Assets" ]] || { echo "Set HH_UNITY_PROJECT to a Blueprinter Editor Unity project"; exit 1; }
export B52_BUILD_DIR="$(winpath "$ROOT/build")"           # where HangarBuilder writes the .nobp
mkdir -p build blender/out unity/Mods/HeavyHangar

# The Unity project sees this repo through links, so the repo's files are what gets built. A project that already
# has NO-B52's tools (Assets/Editor/B52Tools) has the same HangarBuilder, so only the mod folder is linked there.
link_dir "$ROOT/unity/Mods/HeavyHangar" "$HH_UNITY_PROJECT/Assets/Blueprinter/Mods/HeavyHangar"
[[ -e "$HH_UNITY_PROJECT/Assets/Editor/B52Tools/HangarBuilder.cs" ]] || link_dir "$ROOT/unity/Editor" "$HH_UNITY_PROJECT/Assets/Editor/HeavyHangar"
unity_prepare
step "Hangar textures"      ""       "$PYTHON" tools/make_hangar_textures.py
step "Blender hangar"       "HANGAR" blender_run --factory-startup --python tools/blender_hangar.py -- "$(winpath "$ROOT/unity/Mods/HeavyHangar")"
step "Unity hangar prefab"  ""       unity_run B52Tools.HangarBuilder.Build "$LOGS/unity_hangar_editor.log"
cat "$HH_UNITY_PROJECT/HangarBuild.log" || true
step "Unity hangar bundle"  "\[Blueprinter\] (Built|Missing)" unity_run B52Tools.HangarBuilder.BuildMod "$LOGS/unity_hangar_mod_editor.log"
step "Hangar plugin"        "Build succeeded|warning" dotnet build plugin/HeavyHangar -c Release -o build/plugin -p:GameDir="$(winpath "$NO_GAME_DIR")"
ls -la build/*.nobp build/plugin/HeavyHangar.dll
