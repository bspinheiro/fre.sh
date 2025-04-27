#!/bin/bash

# fre.sh - Runs a command in a new terminal window and closes it when done
# Usage: ./fre.sh "command to run"

# Color codes and symbols
_yel_="\033[038;2;255;153;0m"
_grn_="\033[0;32m"
_red_="\033[0;31m"
_rst_="\033[0m"
_ok_="✓"
_ko_="✗"

# Exit on error 
set -e

# Hide cursor and restore at exit
tput civis
trap 'tput cnorm' EXIT

# Debug
DEBUG=0
if [ $DEBUG -eq 1 ]; then
    export PS4=$'\e[38;5;214m+ ${BASH_SOURCE}:${LINENO}:\e[0m \e[36m$BASH_COMMAND\e[0m\n'
    set -x; trap read DEBUG
fi

# Parameters
detected_OS=$(uname -s)

# Utils
warn() { printf "\r   $_red_$_ko_ $*$_rst_\n"; }
chkd() { printf "\r   $_grn_$_ok_ $*$_rst_\n"; }
load() { printf "\r   $_yel_$*$_rst_"; } 
spin() { while [ ! -s "$TMPFILE" ]; do for s in '⠋' '⠙' '⠹' '⠸' '⠼' '⠴'; do load "$s"; sleep 0.1; done; done; EXIT_CODE=$(cat "$TMPFILE"); rm -f "$TMPFILE"; }
rank() { [ -z "$EXIT_CODE" ] && load "  ⏳" && return; [ "$EXIT_CODE" -eq 0 ] && chkd "$ACTION" && unset EXIT_CODE && return; warn "error! Failed to install $APP ($EXIT_CODE)." && unset unset EXIT_CODE; }
uses() { echo "Usage: $0 \"command to run\""; exit 1; }

###
## Install routine
#
install() {
[ $# -eq 0 ] && warn "Error: No command provided." && exit 1
[ $# -eq 1 ] && COMMAND="$1" && APP="$1" && ACTION="installed successfully!"
[ $# -eq 2 ] && COMMAND="$1" && APP="$2" && ACTION="installed successfully!"

TMPFILE=$(mktemp)

echo "📦 $APP"

case "$detected_OS" in
    Darwin*)
        ESCAPED_COMMAND=$(echo "$COMMAND" | sed 's/"/\\"/g')
        APPLESCRIPT=$(cat <<EOF
            tell application "Terminal"
                do script "clear; $ESCAPED_COMMAND; echo \$? > $TMPFILE; exit"
                activate
            end tell
EOF
        )
        rank && osascript -e "$APPLESCRIPT"
        ;;

    Linux*)
        ESCAPED_COMMAND=$(echo "$COMMAND" | sed "s/'/'\\\\''/g")
        if command -v gnome-terminal &> /dev/null; then
            rank && gnome-terminal -- bash -c "$COMMAND; echo \$? > $TMPFILE; exit"
        elif command -v xterm &> /dev/null; then
            rank && xterm -e "bash -c '$ESCAPED_COMMAND; echo \$? > \"$TMPFILE\"; exit'"
        else
            warn "Error: No supported terminal emulator found. Install gnome-terminal or xterm."
            exit 1
        fi
        ;;

    *)
        warn "Unsupported operating system"
        exit 1
        ;;
esac

spin; rank

}

install "zzz" "Zumba"
install "sleep 5" "Homebrew"
install "ttt" "TextNow"
install "sleep 2" "Brew"