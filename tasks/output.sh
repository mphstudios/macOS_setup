#!/bin/sh

CHECK_MARK="\xE2\x9C\x94"

# Prompt for confirmation
#
# @param {String} message  String displayed as the prompt for confirmation
# @param {String} default  Default when the response is empty or not Yes/No
function confirm {
  local message=$1
  local default=$2

  if [[ $default =~ ^([Yy]|yes)$ ]]
  then
    default="Y"
    options="[Yn]"
  else
    default="N"
    options="[yN]"
  fi

  read -p "$message $options " response
  response=${response:-$default}

  [[ $response =~ ^([Yy]|yes)$ ]] && true || false
}

# @param {String} message
function message {
  local string="$1"; shift
  printf "\n$string\n" "$@"
}

# Overwrite previous line with "Skipping ..." message
# @param {String} message
function skip {
  overwrite "Skip $1"
}

# Overwrite previous line
# @see https://stackoverflow.com/questions/11283625/overwrite-last-line-on-terminal
function overwrite {
  echo -e "\r\033[1A\033[0K$@";
}
