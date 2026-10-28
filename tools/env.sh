#!/usr/bin/env bash
# Shared settings for tools/build_hangar.sh (source it; don't run it). Linux, or Windows under Git Bash / MSYS.
# Override any path with an environment variable of the same name:
#   BLENDER, UNITY        the tools
#   HH_UNITY_PROJECT      a Blueprinter Editor Unity project (2022.3.62f2) to build the hangar in
#   NO_GAME_DIR           the Nuclear Option install folder (the one holding NuclearOption.exe)
# Same helpers as NO-B52's tools/env.sh, which builds this hangar too; keep the two in step.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WIN=1 ;;
  *) IS_WIN=0 ;;
esac

if [[ $IS_WIN == 1 ]]; then
  BLENDER="${BLENDER:-/c/Program Files/Blender Foundation/Blender 5.2/blender.exe}"
  UNITY="${UNITY:-/c/Program Files/Unity/Hub/Editor/2022.3.62f2/Editor/Unity.exe}"
  NO_GAME_DIR="${NO_GAME_DIR:-/c/Program Files (x86)/Steam/steamapps/common/Nuclear Option}"
else
  BLENDER="${BLENDER:-$(command -v blender || echo blender)}"
  UNITY="${UNITY:-$HOME/Unity/Hub/Editor/2022.3.62f2/Editor/Unity}"
  NO_GAME_DIR="${NO_GAME_DIR:-$HOME/.steam/steam/steamapps/common/Nuclear Option}"
fi
PYTHON="${PYTHON:-$(command -v python3 || command -v python)}"
LOGS="$ROOT/build/logs"

winpath() { if [[ $IS_WIN == 1 ]]; then cygpath -w "$1"; else printf '%s\n' "$1"; fi; }

game_running() {
  if [[ $IS_WIN == 1 ]]; then tasklist 2>/dev/null | grep -qi "NuclearOption.exe"
  else pgrep -x "NuclearOption.e" >/dev/null 2>&1; fi
}

# link_dir <target> <link>: make <link> point at <target> (a junction on Windows, a symlink elsewhere).
link_dir() {
  local target="$1" link="$2"
  if [[ -e "$link" || -L "$link" ]]; then
    [[ "$(cd "$link" && pwd -P)" == "$(cd "$target" && pwd -P)" ]] && return 0
    echo "$link already exists and isn't this repo's $(basename "$target") (another checkout, such as NO-B52's?)."
    echo "Build from that checkout, or point HH_UNITY_PROJECT at a project of its own."; exit 1
  fi
  mkdir -p "$(dirname "$link")"
  if [[ $IS_WIN == 1 ]]; then cmd //c mklink //J "$(winpath "$link")" "$(winpath "$target")" >/dev/null
  else ln -s "$target" "$link"; fi
}

# step <title> <summary-regex> <command...>: output to build/logs/<title>.log; stops the build on failure.
step() {
  local title="$1" pattern="$2"; shift 2
  local log="$LOGS/$(echo "$title" | tr -c 'A-Za-z0-9\n' '_').log"
  mkdir -p "$LOGS"
  echo "== $title"
  if ! "$@" >"$log" 2>&1; then echo "!! $title failed (log: $log)"; tail -n 25 "$log"; exit 1; fi
  local errors="Traceback|error CS[0-9]+|: error [A-Z]+[0-9]+|FAILED"
  if grep -qE "$errors" "$log"; then echo "!! $title reported errors (log: $log)"; grep -E "$errors" "$log" | head -n 10; exit 1; fi
  [[ -n "$pattern" ]] && { grep -E "$pattern" "$log" || true; }
  return 0
}

# Blueprinter keeps the game's own assemblies in Library/ScriptAssemblies, read-only. Batch mode can't compile over
# them and Blueprinter's own sync never runs in batch mode, so: a compile pass with them writable, then the game's
# copies back, read-only.
GAME_DLLS=(Assembly-CSharp.dll Assembly-CSharp-firstpass.dll)
unity_prepare() {
  local sa="$HH_UNITY_PROJECT/Library/ScriptAssemblies"
  mkdir -p "$sa"
  for f in "${GAME_DLLS[@]}"; do [[ -f "$sa/$f" ]] && chmod u+w "$sa/$f"; done
  step "Unity compile" "" "$UNITY" -batchmode -nographics -quit -projectPath "$(winpath "$HH_UNITY_PROJECT")" \
    -logFile "$(winpath "$LOGS/unity_compile_editor.log")"
  for f in "${GAME_DLLS[@]}"; do
    [[ -f "$sa/$f" ]] && chmod u+w "$sa/$f"
    cp "$HH_UNITY_PROJECT/Packages/nuclearoption/$f" "$sa/$f"
    chmod a-w "$sa/$f"
  done
}

unity_run() {
  "$UNITY" -batchmode -nographics -quit -projectPath "$(winpath "$HH_UNITY_PROJECT")" -logFile "$(winpath "$2")" -executeMethod "$1"
}

blender_run() { "$BLENDER" -b --python-exit-code 1 "$@"; }
