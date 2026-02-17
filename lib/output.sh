# Shared output functions and symbols for mise tasks
# Usage: source "${MISE_PROJECT_DIR}/lib/output.sh"
# Respects NO_COLOR (https://no-color.org)

# Ensure Homebrew is on PATH (Apple Silicon installs to /opt/homebrew)
if ! command -v brew &>/dev/null; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

if [[ -t 1 ]] && [[ -z "${NO_COLOR-}" ]]; then
  GREEN=$'\033[32m' BLUE=$'\033[34m' YELLOW=$'\033[33m' RED=$'\033[31m' RESET=$'\033[0m'
else
  GREEN='' BLUE='' YELLOW='' RED='' RESET=''
fi

# Coloured symbols — usable directly in printf
STATUS_FAIL="${RED}✖${RESET}"
STATUS_INFO="${BLUE}→${RESET}"
STATUS_OK="${GREEN}✔${RESET}"
STATUS_SKIP="${BLUE}⊘${RESET}"
STATUS_WARN="${YELLOW}⚠${RESET}"

die()     { printf "  ${STATUS_FAIL} %s\n" "$1" >&2; exit 1; }
info()    { printf "  ${STATUS_INFO} %s\n" "$1"; }
ok()      { printf "  ${STATUS_OK} %s\n" "$1"; }
skip()    { printf "  ${STATUS_SKIP} %s (skipped)\n" "$1"; }
warn()    { printf "  ${STATUS_WARN} %s\n" "$1" >&2; }
