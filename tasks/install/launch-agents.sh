#!/bin/bash
set -euo pipefail

#MISE description="Sync LaunchAgents and install notifier scripts"

source "${MISE_PROJECT_DIR}/lib/output.sh"

command -v brew &>/dev/null || die "Homebrew is required — run 'mise run install:homebrew'"
command -v envsubst &>/dev/null || die "envsubst is required (via gettext) — 'brew install gettext'"
# Install notification tool (dependency of the notifier script)
# Prefer alerter (alert-style, stays on screen) but fall back to
# terminal-notifier on Intel where alerter has no x86_64 binary.
# @see https://github.com/vjeantet/alerter
if [[ "$(uname -m)" == "arm64" ]]; then
  brew install vjeantet/tap/alerter 2>/dev/null
else
  brew install terminal-notifier 2>/dev/null
fi

# Install consolidated notifier script and icons
BIN_PATH="$HOME/.local/bin/package-updates-notifier"
BIN_SRC="$MISE_PROJECT_DIR/system/bin/package-updates-notifier"
mkdir -p "$(dirname "$BIN_PATH")"
if [[ -f "$BIN_PATH" ]] && diff -q "$BIN_SRC" "$BIN_PATH" >/dev/null 2>&1; then
  verified "package-updates-notifier"
else
  verb="Installed"
  [[ -f "$BIN_PATH" ]] && verb="Updated"
  install -m 755 "$BIN_SRC" "$BIN_PATH"
  ok "$verb: package-updates-notifier"
fi

# Install notification icons (used by --appIcon in alerter)
ICONS_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/package-updates-notifier/icons"
mkdir -p "$ICONS_DIR"
icons_changed=false
for icon in "$MISE_PROJECT_DIR/system/assets/icons"/*.png; do
  [[ -f "$icon" ]] || continue
  name=$(basename "$icon")
  if [[ -f "$ICONS_DIR/$name" ]] && diff -q "$icon" "$ICONS_DIR/$name" >/dev/null 2>&1; then
    continue
  fi
  install -m 644 "$icon" "$ICONS_DIR/$name"
  icons_changed=true
done
if [[ "$icons_changed" == "true" ]]; then
  ok "Installed: notification icons"
else
  verified "notification icons"
fi

# --- LaunchAgent Lifecycle ---
# Only manages agents in the local.* namespace (never touches system/third-party)
REPO_LAUNCH_AGENTS="$MISE_PROJECT_DIR/system/LaunchAgents"
USER_LAUNCH_AGENTS="$HOME/Library/LaunchAgents"
USER_ID=$(id -u)

mkdir -p "$USER_LAUNCH_AGENTS"

# Install a plist, substituting placeholders for install-time values via envsubst.
# Approved list so that only ${BREW_PREFIX} and ${HOME} expand; any other
# $VAR references in plists are left literal for shell runtime expansion.
install_plist() {
  local src="$1" dest="$2"
  BREW_PREFIX="$(brew --prefix)" envsubst '${BREW_PREFIX} ${HOME}' < "$src" > "$dest"
}

# Install or update agents using this repository as the source, outcomes:
#   verified  → installed agent matches source; nothing to do
#   updated   → installed and source differ; bootout, rewrite, bootstrap agent
#   installed → no installed copy; write and bootstrap agent
for plist in "$REPO_LAUNCH_AGENTS"/local.*.plist; do
  [[ -f "$plist" ]] || continue
  name=$(basename "$plist")
  label="${name%.plist}"
  dest="$USER_LAUNCH_AGENTS/$name"
  resolved=$(install_plist "$plist" /dev/stdout)

  # Skip if the installed copy already matches the resolved source.
  if [[ -f "$dest" && "$resolved" == "$(cat "$dest")" ]]; then
    verified "$name"
    continue
  fi

  # Unload the existing agent so bootstrap doesn't collide with its label.
  # `|| true` absorbs the "not loaded" error when the label isn't registered.
  if [[ -f "$dest" ]]; then
    launchctl bootout "gui/$USER_ID/$label" 2>/dev/null || true
    verb="Updated"
  else
    verb="Installed"
  fi

  install_plist "$plist" "$dest"

  # Surface bootstrap errors with context since set -e would otherwise dump an
  # opaque "Bootstrap failed: <errno>" with no indication of which plist
  # failed or that its file was already written to disk.
  if ! err=$(launchctl bootstrap "gui/$USER_ID" "$dest" 2>&1); then
    die "$name: file written to $dest but launchctl bootstrap failed — $err"
  fi

  ok "$verb: $name"
done

# Remove any stale agents that are no longer in this repository
for plist in "$USER_LAUNCH_AGENTS"/local.*.plist; do
  [[ -f "$plist" ]] || continue
  name=$(basename "$plist")
  label="${name%.plist}"
  if [[ ! -f "$REPO_LAUNCH_AGENTS/$name" ]]; then
    launchctl bootout "gui/$USER_ID/$label" 2>/dev/null || true
    rm -f "$plist"
    ok "Removed stale: $name"
  fi
done
