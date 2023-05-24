#!/bin/sh

CHECK_MARK="\xE2\x9C\x94"

# @param {String} message
function message {
  local string="$1"; shift
  printf "\n$string\n" "$@"
}

# Overwrite previous line
# @see https://stackoverflow.com/questions/11283625/overwrite-last-line-on-terminal
function overwrite {
  echo -e "\r\033[1A\033[0K$@";
}
