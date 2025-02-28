#!/bin/bash
# Build the app
swift build

# Open the app using the open command
open .build/debug/SteamShortcutCreator

# Optionally - if you want to wait for the app to be closed before ending the script:
# wait 