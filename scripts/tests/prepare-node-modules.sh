#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
work="$(mktemp -d)"
export test_app="$work/app with spaces" events="$work/events"
mkdir -p "$test_app/node_modules"
printf '{}\n' > "$test_app/package.json"
printf 'keep host dependencies\n' > "$test_app/node_modules/host-dependency"
cleanup() {
  rm -f "$events" "$test_app/package.json" "$test_app/node_modules/host-dependency"
  rmdir "$test_app/node_modules" "$test_app" "$work"
}
trap cleanup EXIT

mountpoint() { [ "$test_mounted" = yes ]; }
ln() {
  printf 'ln\n' >> "$events"
  if [ "$test_links" = readable ]; then
    command cp "$(dirname "$3")/$2" "$3"
  fi
}
mkdir() {
  [ "$#" -eq 3 ] && [ "$1" = -p ]
  [ "$2" = "$HOME/.cache/workshop-node-modules" ] && [ "$3" = "$test_app/node_modules" ]
  command mkdir -p "$3"
}
sudo() {
  [ "$#" -eq 4 ] && [ "$1" = mount ] && [ "$2" = --bind ]
  [ "$3" = "$HOME/.cache/workshop-node-modules" ] && [ "$4" = "$test_app/node_modules" ]
  printf 'mount\n' >> "$events"
}
export -f mountpoint ln mkdir sudo

run_case() {
  local platform="$1" expected="$3"
  export test_links="$2" test_mounted="${4:-no}"
  : > "$events"
  if [ "$platform" = legacy ]; then
    bash "$ROOT/chapters/support/bin/prepare-node-modules" "$test_app"
  else
    bash "$ROOT/chapters/support/bin/prepare-node-modules" "$test_app" "$platform"
  fi
  [ "$(cat "$events")" = "$expected" ] || { echo "Unexpected operations for $platform" >&2; exit 1; }
  [ "$(cat "$test_app/node_modules/host-dependency")" = 'keep host dependencies' ]
  ! compgen -G "$test_app/.workshop-link-check.*" >/dev/null
}
run_case Windows missing mount
run_case Windows readable mount
run_case Windows missing '' yes
run_case Linux readable ln
run_case Darwin missing $'ln\nmount'
run_case legacy missing $'ln\nmount'
printf 'Windows avoids symlink probes; other platforms retain probing and native storage fallback.\n'
