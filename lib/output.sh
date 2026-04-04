# Shared output functions and symbols for mise tasks
# Usage: source "${MISE_PROJECT_DIR}/lib/output.sh"
# Respects NO_COLOR (https://no-color.org) and FORCE_COLOR

if [[ -t 1 ]] || [[ -n "${FORCE_COLOR:-}" ]]; then
  GREEN=$'\033[32m' BLUE=$'\033[34m' YELLOW=$'\033[33m' RED=$'\033[31m' RESET=$'\033[0m'
else
  GREEN='' BLUE='' YELLOW='' RED='' RESET=''
fi

[[ -n "${NO_COLOR:-}" ]] && GREEN='' BLUE='' YELLOW='' RED='' RESET=''

# Coloured symbols — usable directly in printf
STATUS_FAIL="${RED}✖${RESET}"
STATUS_INFO="${BLUE}→${RESET}"
STATUS_OK="${GREEN}✔${RESET}"
STATUS_SKIP="${BLUE}⊘${RESET}"
STATUS_WARN="${YELLOW}⚠${RESET}"

die()     { printf "  %s %s\n" "${STATUS_FAIL}" "$1" >&2; exit 1; }
info()    { printf "  %s %s\n" "${STATUS_INFO}" "$1"; }
ok()      { printf "  %s %s\n" "${STATUS_OK}" "$1"; }
skip()     { printf "  %s %s (skipped)\n"  "${STATUS_SKIP}" "$1"; }
verified() { printf "  %s %s (verified)\n" "${STATUS_OK}"   "$1"; }
warn()    { printf "  %s %s\n" "${STATUS_WARN}" "$1" >&2; }

# spin TITLE CMD [ARGS…]
# Shows a gum spinner while running CMD; falls back to running CMD directly if gum is unavailable.
spin() {
  local title="$1"; shift
  if command -v gum &>/dev/null; then
    gum spin --spinner dot --title "$title" -- "$@"
  else
    "$@"
  fi
}
