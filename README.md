# Steam Shortcut Creator for macOS

A SwiftUI app that provides a user-friendly interface for the [Steam macOS Shortcut Creator](https://github.com/entwickler42/Steam-Shortcuts-Python) Python script.

## Features

- Intuitive user interface for adding macOS applications to Steam
- Drag and drop support for .app bundles
- Configure all script options through the UI
- Automatically updates the script repository from GitHub
- Live log output and status updates
- Proper icon handling for all applications

## Requirements

- macOS 12.0 or later
- Python 3.6 or later
- Git (for repository updates)

## Installation

1. Download the latest release from the [Releases](https://github.com/entwickler42/Steam-Shortcuts-SwiftUI/releases) page
2. Move the app to your Applications folder
3. Launch the app

The first time you launch the app, it will automatically clone the repository and set up everything needed to run the script.

## Usage

1. Add applications by dragging .app bundles to the app or clicking the "Add..." button
2. Configure options as needed:
   - Steam User ID (optional)
   - Icon size (default: 128px)
   - Overwrite existing shortcuts
   - Create new shortcuts.vdf file
   - Clear Steam's HTTP cache
   - Show debug information
3. Click "Create Shortcuts" to add the applications to Steam
4. View the log output to confirm success

## Development

To build the app from source:

1. Clone this repository
2. Open Terminal and navigate to the SteamShortcutCreator directory
3. Run `swift build` to build the app
4. Run `swift run` to run the app

Or use Xcode:

1. Clone this repository
2. Run `xed .` in the SteamShortcutCreator directory to open in Xcode
3. Build and run the app from Xcode

## Troubleshooting

If you encounter issues:

- Check the log output in the app for error messages
- Ensure Python 3 is installed and available in your PATH
- Verify Git is installed for repository updates
- If repository updates fail, try clicking the "Update" button to retry

## License

This project is licensed under the MIT License - see the parent repository for details. 