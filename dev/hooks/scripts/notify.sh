#!/bin/bash
# Notification script for dev plugin
# Usage: notify.sh [type] [message]
# Types: stop, question, error, warning, success, progress
# Clicking notification focuses the terminal (requires terminal-notifier on macOS)

TYPE="${1:-stop}"
CUSTOM_MESSAGE="${2:-}"

# Script directory for resolving paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find parent IDE PID by walking up process tree (for JetBrains IDEs)
get_parent_ide_pid() {
  local pid=$$
  local max_depth=20
  local depth=0

  while [[ $depth -lt $max_depth ]]; do
    # Get parent PID and command
    local parent_info=$(ps -p "$pid" -o ppid=,comm= 2>/dev/null)
    local ppid=$(echo "$parent_info" | awk '{print $1}')
    local comm=$(echo "$parent_info" | awk '{print $2}')

    # Check if this is a JetBrains IDE (webstorm, idea, pycharm, etc.)
    if [[ "$comm" =~ (webstorm|idea|pycharm|clion|goland|rubymine|rider|phpstorm|datagrip) ]]; then
      echo "$pid"
      return
    fi

    # Stop if we hit init/launchd (PID 1) or invalid
    if [[ "$ppid" -le 1 || -z "$ppid" ]]; then
      break
    fi

    pid="$ppid"
    ((depth++))
  done

  echo ""
}

# Detect terminal bundle ID (for macOS activation)
get_terminal_bundle_id() {
  # Check for JetBrains IDEs first (IntelliJ, WebStorm, PyCharm, etc.)
  if [[ "${TERMINAL_EMULATOR:-}" == "JetBrains-JediTerm" ]]; then
    echo "${__CFBundleIdentifier:-com.jetbrains.intellij}"
    return
  fi

  case "${TERM_PROGRAM:-}" in
    "iTerm.app") echo "com.googlecode.iterm2" ;;
    "Apple_Terminal") echo "com.apple.Terminal" ;;
    "vscode") echo "com.microsoft.VSCode" ;;
    "WarpTerminal") echo "dev.warp.Warp-Stable" ;;
    "Hyper") echo "co.zeit.hyper" ;;
    "Alacritty") echo "org.alacritty" ;;
    "Cursor") echo "com.todesktop.230313mzl4w4u92" ;;
    *)
      if [[ -n "${__CFBundleIdentifier:-}" ]]; then
        echo "$__CFBundleIdentifier"
      else
        echo "com.apple.Terminal"
      fi
      ;;
  esac
}

# Get notification details based on type
get_notification_details() {
  local type="$1"
  local custom_msg="$2"

  case "$type" in
    "question")
      echo "Input Needed"
      echo "${custom_msg:-Your input is required}"
      echo "/System/Library/Sounds/Glass.aiff"
      ;;
    "error")
      echo "Error"
      echo "${custom_msg:-Something went wrong}"
      echo "/System/Library/Sounds/Basso.aiff"
      ;;
    "warning")
      echo "Warning"
      echo "${custom_msg:-Attention required}"
      echo "/System/Library/Sounds/Sosumi.aiff"
      ;;
    "success")
      echo "Success"
      echo "${custom_msg:-Task completed successfully}"
      echo "/System/Library/Sounds/Glass.aiff"
      ;;
    "progress")
      echo "In Progress"
      echo "${custom_msg:-Working on task...}"
      echo "/System/Library/Sounds/Tink.aiff"
      ;;
    "stop"|*)
      echo "Complete"
      echo "${custom_msg:-Task complete}"
      echo "/System/Library/Sounds/Ping.aiff"
      ;;
  esac
}

# macOS notification with click-to-focus
macos_notify() {
  local subtitle="$1"
  local message="$2"
  local sound="$3"
  local bundle_id
  bundle_id=$(get_terminal_bundle_id)

  # Play sound
  if [[ -f "$sound" ]]; then
    afplay "$sound" 2>/dev/null &
  fi

  # terminal-notifier with grouping and click-to-activate
  # Note: Icon is customized by replacing terminal-notifier.app's icon
  if command -v terminal-notifier &>/dev/null; then
    # For JetBrains IDEs, use PID-based activation to focus the correct instance
    local ide_pid=$(get_parent_ide_pid)

    if [[ -n "$ide_pid" ]]; then
      # Use -execute with AppleScript to activate specific IDE instance by PID
      terminal-notifier \
        -title "Claude Code" \
        -subtitle "$subtitle" \
        -message "$message" \
        -group "claude-code" \
        -execute "osascript -e 'tell application \"System Events\" to set frontmost of (first process whose unix id is $ide_pid) to true'" \
        -ignoreDnD \
        2>/dev/null &
    else
      # Fallback to bundle ID activation for non-JetBrains terminals
      terminal-notifier \
        -title "Claude Code" \
        -subtitle "$subtitle" \
        -message "$message" \
        -group "claude-code" \
        -activate "$bundle_id" \
        -ignoreDnD \
        2>/dev/null &
    fi
  else
    # Fallback: basic notification without click action
    osascript -e "display notification \"$message\" with title \"Claude Code\" subtitle \"$subtitle\"" 2>/dev/null &
  fi
}

# Linux notification
linux_notify() {
  local subtitle="$1"
  local message="$2"
  local sound="$3"
  local urgency="normal"

  # Set urgency based on subtitle
  case "$subtitle" in
    "Error") urgency="critical" ;;
    "Warning") urgency="normal" ;;
    *) urgency="low" ;;
  esac

  # Play sound
  if [[ -f "$sound" ]]; then
    paplay "$sound" 2>/dev/null &
  fi

  if command -v notify-send &>/dev/null; then
    notify-send \
      -u "$urgency" \
      -a "Claude Code" \
      -c "im.received" \
      "Claude Code - $subtitle" \
      "$message" \
      2>/dev/null &
  fi
}

# Main logic
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Read notification details (subtitle, message, sound)
  details=$(get_notification_details "$TYPE" "$CUSTOM_MESSAGE")
  subtitle=$(echo "$details" | sed -n '1p')
  message=$(echo "$details" | sed -n '2p')
  sound=$(echo "$details" | sed -n '3p')

  macos_notify "$subtitle" "$message" "$sound"

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  details=$(get_notification_details "$TYPE" "$CUSTOM_MESSAGE")
  subtitle=$(echo "$details" | sed -n '1p')
  message=$(echo "$details" | sed -n '2p')
  sound="${details##*$'\n'}"
  # Linux sounds
  case "$TYPE" in
    "error") sound="/usr/share/sounds/freedesktop/stereo/dialog-error.oga" ;;
    "warning") sound="/usr/share/sounds/freedesktop/stereo/dialog-warning.oga" ;;
    "question") sound="/usr/share/sounds/freedesktop/stereo/message.oga" ;;
    *) sound="/usr/share/sounds/freedesktop/stereo/complete.oga" ;;
  esac

  linux_notify "$subtitle" "$message" "$sound"
fi

exit 0
