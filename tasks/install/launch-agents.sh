#!/bin/bash
set -euo pipefail

#MISE description="Sync LaunchAgents and install notifier scripts"
#MISE confirm="Sync LaunchAgents?"
#MISE depends=["install:homebrew"]

source "${MISE_PROJECT_DIR}/lib/output.sh"

# Install terminal-notifier (dependency of the notifier script)
brew install terminal-notifier 2>/dev/null || true

# Install consolidated notifier script
notifier_dest="$(brew --prefix)/bin/package-updates-notifier"
if [[ -f "$notifier_dest" ]] && diff -q "$MISE_PROJECT_DIR/bin/package-updates-notifier" "$notifier_dest" >/dev/null 2>&1; then
  skip "package-updates-notifier (current)"
else
  verb="Installed"
  [[ -f "$notifier_dest" ]] && verb="Updated"
  install -m 755 "$MISE_PROJECT_DIR/bin/package-updates-notifier" "$notifier_dest"
  ok "$verb: package-updates-notifier"
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
