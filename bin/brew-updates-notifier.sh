#!/bin/bash
#
# Display Homebrew updates in Notification Center on Mac OS X
# Author: Matt Stevens, codeworkshop.net
# http://codeworkshop.net/posts/notification-center-updates-for-homebrew
#
# Requires: terminal-notifier (available via Homebrew)
#
export PATH=/usr/local/bin:$PATH

sleep 10 # give the network a chance to connect on wake from sleep

brew update > /dev/null 2>&1
outdated=`brew outdated | sort`

if [ ! -z "$outdated" ]; then
    terminal-notifier \
        -group homebrew-updates-notifier \
        -title "Homebrew Updates Available" \
        -message "$outdated" \
        -sender com.apple.Terminal > /dev/null 2>&1
fi
