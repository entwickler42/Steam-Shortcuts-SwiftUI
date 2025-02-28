#!/bin/bash

# Create a package.app directory structure
mkdir -p SteamShortcutCreator.app/Contents/MacOS
mkdir -p SteamShortcutCreator.app/Contents/Resources

# Build the app
swift build -c release

# Copy the executable
cp .build/release/SteamShortcutCreator SteamShortcutCreator.app/Contents/MacOS/

# Create Info.plist
cat > SteamShortcutCreator.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>SteamShortcutCreator</string>
    <key>CFBundleIdentifier</key>
    <string>com.example.SteamShortcutCreator</string>
    <key>CFBundleName</key>
    <string>Steam Shortcut Creator</string>
    <key>CFBundleDisplayName</key>
    <string>Steam Shortcut Creator</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

echo "App bundle created at $(pwd)/SteamShortcutCreator.app"
echo "You can now open it using 'open SteamShortcutCreator.app'" 