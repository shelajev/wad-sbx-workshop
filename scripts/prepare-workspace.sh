#!/usr/bin/env bash
# HOST: prepare dependency storage inside an existing workshop sandbox.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
. "$ROOT/scripts/common.sh"
[ "$#" -ge 1 ] && [ "$#" -le 2 ] || die 'Usage: scripts/prepare-workspace.sh sandbox-name [application-path]'
name="$1"
app="$(cd "${2:-$ROOT/sample-app}" && pwd)"
MSYS2_ARG_CONV_EXCL='*' sbx exec -i "$name" bash -s -- "$app" "$(host_os)" < "$ROOT/chapters/support/bin/prepare-node-modules"
