import SwiftUI
import AppKit

@main
struct SteamShortcutCreatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 500)
        }
        .windowStyle(.hiddenTitleBar)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About Steam Shortcut Creator") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            NSApplication.AboutPanelOptionKey.applicationName: "Steam Shortcut Creator",
                            NSApplication.AboutPanelOptionKey.applicationVersion: "1.0.0",
                            NSApplication.AboutPanelOptionKey.credits: NSAttributedString(
                                string: "A macOS UI for Steam macOS Shortcut Creator"
                            )
                        ]
                    )
                }
            }
        }
    }
} 