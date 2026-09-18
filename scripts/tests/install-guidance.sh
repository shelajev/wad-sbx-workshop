#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
cat > "$scratch/bin/acr" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
if [ -n "${GH_TOKEN+x}" ] || [ -n "${GITHUB_TOKEN+x}" ]; then
  echo 'GitHub placeholders reached ACR' >&2
  exit 1
fi
command="$1"
shift
printf '%s\n' "$@" > "$ACR_TEST_LOG/$command"
case "$command" in
  install) ;;
  realize)
    for agent in .claude .codex; do
      skill="$agent/skills/acr__shelajev__coding-policy__review-change/SKILL.md"
      mkdir -p "$(dirname "$skill")"
      if [ "${ACR_TEST_MISSING_SKILL:-0}" != 1 ]; then
        printf 'Review the requested commit.\n' > "$skill"
      fi
    done
    ;;
  check) exit "${ACR_TEST_CHECK_STATUS:-0}" ;;
  *) exit 2 ;;
esac
STUB
chmod +x "$scratch/bin/acr"

setup_case() {
  case_root="$scratch/$1"
  mkdir -p "$case_root/home/work" "$case_root/project with spaces" "$case_root/log"
  printf '%s\n' "$case_root/project with spaces" > "$case_root/home/work/app-path"
}

run_guidance() {
  HOME="$case_root/home" PATH="$scratch/bin:$PATH" ACR_TEST_LOG="$case_root/log" \
    GH_TOKEN=placeholder GITHUB_TOKEN=placeholder bash "$root/chapters/support/bin/install-guidance"
}

expect_arguments() {
  command="$1"
  shift
  printf '%s\n' "$@" > "$case_root/expected"
  diff -u "$case_root/expected" "$case_root/log/$command"
}

package=github:shelajev/coding-policy@b85031eb0c8963b28b63eaa12efcbd34c850d32d
setup_case new
run_guidance
expect_arguments install "$package" --if-missing --non-interactive --agent claude-code --agent codex --freshness none
expect_arguments realize --agent claude-code --agent codex
expect_arguments check --agent claude-code --agent codex

setup_case existing
printf 'schemaVersion: 2\nagents: [cursor]\nfreshness: install\n' > "$case_root/project with spaces/agents.yaml"
run_guidance
expect_arguments install "$package" --if-missing --non-interactive
expect_arguments realize --agent claude-code --agent codex
expect_arguments check --agent claude-code --agent codex

setup_case missing-skill
if ACR_TEST_MISSING_SKILL=1 run_guidance 2> "$case_root/error"; then
  echo 'Missing review skill incorrectly succeeded' >&2
  exit 1
fi
grep -q 'Required review skill is missing' "$case_root/error"
[ ! -e "$case_root/log/check" ]

setup_case failed-check
status=0
ACR_TEST_CHECK_STATUS=7 run_guidance || status=$?
[ "$status" -eq 7 ] || { echo "Expected check failure 7, got $status" >&2; exit 1; }
printf 'install-guidance tests passed\n'
