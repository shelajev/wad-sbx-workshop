#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
command -v node >/dev/null 2>&1 || { echo 'Node.js is required for the JSON stub.' >&2; exit 1; }
scratch="$(mktemp -d "${TMPDIR:-/tmp}/workshop-notify.XXXXXX")"
cleanup() {
  case "$scratch" in "${TMPDIR:-/tmp}"/workshop-notify.*) rm -rf "$scratch" ;; esac
}
trap cleanup EXIT
export FACTORY_DIR="$scratch/factory" prompt_log="$scratch/prompts"
mkdir -p "$FACTORY_DIR/claims/unrelated"
printf '{}\n' > "$FACTORY_DIR/state.json"
printf 'keep\n' > "$FACTORY_DIR/claims/unrelated/claimed_at"
: > "$prompt_log"

jq() {
  node -e 'const x = JSON.parse(require("fs").readFileSync(process.argv[2] || 0, "utf8"));
    const query = process.argv[1];
    if (query === ".result.agent.agent_status // \"unknown\"") console.log(x.result.agent.agent_status);
    else if (query === ".error.code // \"unknown\"") console.log(x.error.code);
    else process.exit(2);' "$2" "${3:-}"
}
herdr() {
  case "$1 $2" in
    'agent get')
      if [ "${extra_claim_file:-0}" = 1 ]; then
        printf 'keep\n' > "$FACTORY_DIR/claims/$test_key/other-owner"
      fi
      printf '{"result":{"agent":{"agent_status":"%s"}}}\n' "$test_state"
      ;;
    'agent read') printf 'Do you trust this workspace?\n' ;;
    'agent prompt')
      printf '%s\n' "$test_key" >> "$prompt_log"
      case "$test_reply" in
        success) printf '{"result":{}}\n' ;;
        blocked) printf '{"error":{"code":"agent_blocked"}}\n' ;;
        unknown) printf '{"error":{"code":"transport_unknown"}}\n' ;;
        failed) return 1 ;;
      esac
      ;;
    *) return 2 ;;
  esac
}
export -f jq herdr

notify() {
  export test_key="$1" test_state="$2" test_reply="$3"
  local expected="$4" status=0
  bash "$ROOT/chapters/support/bin/crew-notify" qa --key "$test_key" \
    --message-id "msg-$test_key" --text 'Read your message.' > "$scratch/output" 2>&1 || status=$?
  [ "$status" -eq "$expected" ] || { cat "$scratch/output" >&2; echo "Expected $expected for $test_key, got $status" >&2; exit 1; }
  [ "$(cat "$FACTORY_DIR/claims/unrelated/claimed_at")" = keep ]
}
notify busy-retry working success 3
[ ! -e "$FACTORY_DIR/claims/busy-retry" ] && [ ! -s "$prompt_log" ]
notify busy-retry idle success 0
[ -f "$FACTORY_DIR/claims/busy-retry/claimed_at" ]
notify busy-retry idle success 9
[ "$(cat "$prompt_log")" = busy-retry ]

notify blocked blocked success 4
[ ! -e "$FACTORY_DIR/claims/blocked" ]
notify unknown-state unknown success 4
[ ! -e "$FACTORY_DIR/claims/unknown-state" ]
notify rejected idle blocked 4
[ ! -e "$FACTORY_DIR/claims/rejected" ]

for reply in unknown failed; do
  notify "uncertain-$reply" idle "$reply" 5
  [ -f "$FACTORY_DIR/claims/uncertain-$reply/claimed_at" ]
  attempts="$(wc -l < "$prompt_log")"
  notify "uncertain-$reply" idle success 9
  [ "$(wc -l < "$prompt_log")" -eq "$attempts" ]
done
export extra_claim_file=1
notify foreign-file working success 3
[ ! -e "$FACTORY_DIR/claims/foreign-file/claimed_at" ]
[ "$(cat "$FACTORY_DIR/claims/foreign-file/other-owner")" = keep ]
printf 'Busy and blocked claims release; acknowledged and uncertain deliveries stay claimed.\n'
