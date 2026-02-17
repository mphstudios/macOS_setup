#!/bin/bash

#MISE description="Export macOS defaults for a domain"

#USAGE arg "<domain>" help="e.g. com.apple.dock"

macos-defaults dump -d "${usage_domain}"
