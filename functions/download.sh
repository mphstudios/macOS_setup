#!/bin/sh

function download {
  local filename=$1
  if [ ! -f "$SRC_DIR/$filename" ]; then
    printf "%s\n" "Downloading $filename"
    curl --fail --remote-name --retry 3 --retry-delay 5 --show-error --silent $REPOSITORY/$filename
  fi
}

export -f download