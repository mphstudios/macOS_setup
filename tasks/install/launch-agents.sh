#!/bin/bash
set -euo pipefail

#MISE description="Sync LaunchAgents and install notifier scripts"

source "${MISE_PROJECT_DIR}/lib/output.sh"

command -v brew &>/dev/null || die "Homebrew is required — run 'mise run install:homebrew'"
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
BIN_DIR="$(brew --prefix)/bin/package-updates-notifier"
BIN_SRC="$MISE_PROJECT_DIR/system/bin/package-updates-notifier"
if [[ -f "$BIN_DIR" ]] && diff -q "$BIN_SRC" "$BIN_DIR" >/dev/null 2>&1; then
  verified "package-updates-notifier"
else
  verb="Installed"
  [[ -f "$BIN_DIR" ]] && verb="Updated"
  install -m 755 "$BIN_SRC" "$BIN_DIR"
  ok "$verb: package-updates-notifier"
fi

# Install notification icons (used by --appIcon in alerter)
ICON_DEST="$(brew --prefix)/share/package-updates-notifier"
mkdir -p "$ICON_DEST"
icons_changed=false
for icon in "$MISE_PROJECT_DIR/system/assets/icons"/*.png; do
  [[ -f "$icon" ]] || continue
  name=$(basename "$icon")
  if [[ -f "$ICON_DEST/$name" ]] && diff -q "$icon" "$ICON_DEST/$name" >/dev/null 2>&1; then
    continue
  fi
  install -m 644 "$icon" "$ICON_DEST/$name"
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
BREW_PREFIX="$(brew --prefix)"

mkdir -p "$USER_LAUNCH_AGENTS"

# Install a plist, substituting BREW_PREFIX placeholder for the actual path.
# Plists use __BREW_PREFIX__ so they work on both Intel and Apple Silicon.
install_plist() {
  local src="$1" dest="$2"
  sed "s|__BREW_PREFIX__|$BREW_PREFIX|g" "$src" > "$dest"
  chmod 644 "$dest"
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
