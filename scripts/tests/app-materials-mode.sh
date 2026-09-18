#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
. "$ROOT/scripts/common.sh"
mkdir -p "$ROOT/.local"
work="$(mktemp -d "$ROOT/.local/materials-mode-test.XXXXXX")"
cleanup() {
  case "$work" in "$ROOT"/.local/materials-mode-test.*) rm -rf -- "$work" ;; esac
}
trap cleanup EXIT
mkdir -p "$work/bin" "$work/materials"
printf 'fixture bundle\n' > "$work/materials/incident-triage-board.bundle"
printf '%s  incident-triage-board.bundle\n' "$(sha256_file "$work/materials/incident-triage-board.bundle")" > "$work/materials/SHA256SUMS"

cat > "$work/bin/curl" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
while [ $# -gt 0 ]; do
  case "$1" in
    --output) output="$2"; shift 2 ;;
    --retry) shift 2 ;;
    --*) shift ;;
    *) url="$1"; shift ;;
  esac
done
name="${url##*/}"
printf 'download %s\n' "$name" >> "$MATERIALS_TEST_LOG"
cp "$MATERIALS_TEST_DATA/$name" "$output"
SH
cat > "$work/bin/git" <<'SH'
#!/usr/bin/env bash
set -euo pipefail
if [ "$1" = clone ]; then
  mkdir -p "${@: -1}/.git"
  printf 'clone\n' >> "$MATERIALS_TEST_LOG"
fi
SH
chmod +x "$work/bin/"*

make_fixture() {
  local fixture="$1"
  mkdir -p "$fixture/scripts"
  cp "$ROOT/scripts/get-materials.sh" "$ROOT/scripts/common.sh" "$ROOT/scripts/versions.env" "$fixture/scripts/"
  cat > "$fixture/scripts/download-mcp.sh" <<'SH'
#!/usr/bin/env bash
printf 'adapter\n' >> "$MATERIALS_TEST_LOG"
SH
  cat > "$fixture/scripts/prepare-app.sh" <<'SH'
#!/usr/bin/env bash
printf 'prepare\n' >> "$MATERIALS_TEST_LOG"
SH
  chmod +x "$fixture/scripts/"*.sh
}

for mode in default app-only; do
  fixture="$work/$mode"
  make_fixture "$fixture"
  set --
  [ "$mode" != app-only ] || set -- --app-only
  PATH="$work/bin:$PATH" MATERIALS_TEST_LOG="$fixture/calls" MATERIALS_TEST_DATA="$work/materials" \
    bash "$fixture/scripts/get-materials.sh" "$@" > "$fixture/output" 2>&1
  grep -qx 'download incident-triage-board.bundle' "$fixture/calls"
  grep -qx 'download SHA256SUMS' "$fixture/calls"
  grep -qx clone "$fixture/calls"
  grep -qx prepare "$fixture/calls"
  if [ "$mode" = default ]; then
    grep -qx adapter "$fixture/calls"
  elif grep -qx adapter "$fixture/calls"; then
    die '--app-only downloaded the adapter'
  fi
done

fixture="$work/invalid"
make_fixture "$fixture"
for arguments in '--unknown' '--app-only unexpected'; do
  read -r -a args <<< "$arguments"
  if PATH="$work/bin:$PATH" MATERIALS_TEST_LOG="$fixture/calls" MATERIALS_TEST_DATA="$work/materials" \
    bash "$fixture/scripts/get-materials.sh" "${args[@]}" > "$fixture/output" 2>&1; then
    die "Unexpected arguments accepted: $arguments"
  fi
  grep -q 'Usage:' "$fixture/output"
  [ ! -e "$fixture/calls" ] || die 'Invalid arguments started material setup'
done
printf 'Default and app-only materials setup and argument validation passed.\n'
