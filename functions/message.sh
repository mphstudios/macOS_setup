#!/bin/sh

function message {
  local string="$1"; shift
  printf "\n$string\n" "$@"
}

export -f message
