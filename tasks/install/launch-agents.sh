#!/bin/bash
set -euo pipefail

#MISE description="Sync LaunchAgents and install notifier scripts"
#MISE confirm="Sync LaunchAgents?"
#MISE depends=["install:homebrew"]

source "${MISE_PROJECT_DIR}/lib/output.sh"

# Install notification tool (dependency of the notifier script)
# Prefer alerter (alert-style, stays on screen) but fall back to
# terminal-notifier on Intel where alerter has no x86_64 binary.
# @see https://github.com/vjeantet/alerter
if [[ "$(uname -m)" == "arm64" ]]; then
  brew install vjeantet/tap/alerter 2>/dev/null || true
else
  brew install terminal-notifier 2>/dev/null || true
fi

# Install consolidated notifier script and icons
BIN_DIR="$(brew --prefix)/bin/package-updates-notifier"
BIN_SRC="$MISE_PROJECT_DIR/bin/package-updates-notifier"
if [[ -f "$BIN_DIR" ]] && diff -q "$BIN_SRC" "$BIN_DIR" >/dev/null 2>&1; then
  skip "package-updates-notifier (current)"
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
for icon in "$MISE_PROJECT_DIR/assets/icons"/*.png; do
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
  skip "notification icons (current)"
fi

# --- LaunchAgent Lifecycle ---
# Only manages agents in the local.* namespace (never touches system/third-party)
REPO_AGENTS="$MISE_PROJECT_DIR/LaunchAgents"
USER_AGENTS="$HOME/Library/LaunchAgents"
USER_ID=$(id -u)

mkdir -p "$USER_AGENTS"

# Install or update agents from repo
for plist in "$REPO_AGENTS"/local.*.plist; do
  [[ -f "$plist" ]] || continue
  name=$(basename "$plist")
  label="${name%.plist}"

  if [[ -f "$USER_AGENTS/$name" ]]; then
    # Compare; if changed, bootout → update → bootstrap
    if ! diff -q "$plist" "$USER_AGENTS/$name" >/dev/null 2>&1; then
      launchctl bootout "gui/$USER_ID/$label" 2>/dev/null || true
      cp -fX "$plist" "$USER_AGENTS/$name"
      chmod 644 "$USER_AGENTS/$name"
      launchctl bootstrap "gui/$USER_ID" "$USER_AGENTS/$name"
      ok "Updated: $name"
    else
      skip "$name (current)"
    fi
  else
    # New agent
    cp -fX "$plist" "$USER_AGENTS/$name"
    chmod 644 "$USER_AGENTS/$name"
    launchctl bootstrap "gui/$USER_ID" "$USER_AGENTS/$name"
    ok "Installed: $name"
  fi
done

# Remove stale agents not in repo
for plist in "$USER_AGENTS"/local.*.plist; do
  [[ -f "$plist" ]] || continue
  name=$(basename "$plist")
  label="${name%.plist}"
  if [[ ! -f "$REPO_AGENTS/$name" ]]; then
    launchctl bootout "gui/$USER_ID/$label" 2>/dev/null || true
    rm -f "$plist"
    ok "Removed stale: $name"
  fi
done
