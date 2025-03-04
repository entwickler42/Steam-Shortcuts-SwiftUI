import SwiftUI
import AppKit

@main
struct SteamShortcutCreatorApp: App {
    @StateObject private var gitRepository = GitRepository()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, minHeight: 500)
                .environmentObject(gitRepository)
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
            
            // Add a Repository menu
            CommandMenu("Repository") {
                Button("Open Repository in Finder") {
                    gitRepository.openInFinder()
                }
                .disabled(!FileManager.default.fileExists(atPath: gitRepository.repoPath))
                
                Button("Open Python Script in Editor") {
                    gitRepository.openPythonScriptInEditor()
                }
                .disabled(!FileManager.default.fileExists(atPath: gitRepository.getPythonScriptPath()))
                
                Divider()
                
                Button("Update Repository") {
                    Task {
                        await gitRepository.updateRepository()
                    }
                }
                .disabled(gitRepository.isUpdating)
            }
        }
    }
} 