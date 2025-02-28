import Foundation
import SwiftUI

/// Model for a macOS app to be added to Steam
struct MacOSApp: Identifiable, Hashable {
    let id = UUID()
    let path: String
    let name: String
    let icon: NSImage?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: MacOSApp, rhs: MacOSApp) -> Bool {
        return lhs.id == rhs.id
    }
}

/// Main state for the application
class AppState: ObservableObject, @unchecked Sendable {
    // App selection state
    @Published var selectedApps: [MacOSApp] = []
    
    // Configuration state
    @Published var steamUserId: String = ""
    @Published var iconSize: Double = 128
    @Published var isOverwrite: Bool = false
    @Published var isNewVdf: Bool = false
    @Published var isClearCache: Bool = true
    @Published var isDebug: Bool = false
    
    // Processing state
    @Published var isProcessing: Bool = false
    @Published var status: String = "Ready"
    @Published var logOutput: String = ""
    
    /// Add an app to the selected list
    func addApp(url: URL) {
        guard url.isFileURL && url.pathExtension == "app" else { return }
        
        // Load icon from the app bundle
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        let appName = url.deletingPathExtension().lastPathComponent
        
        let app = MacOSApp(path: url.path, name: appName, icon: icon)
        
        // Don't add duplicates
        DispatchQueue.main.async {
            if !self.selectedApps.contains(where: { $0.path == app.path }) {
                self.selectedApps.append(app)
            }
        }
    }
    
    /// Remove an app from the selected list
    func removeApp(app: MacOSApp) {
        DispatchQueue.main.async {
            self.selectedApps.removeAll(where: { $0.id == app.id })
        }
    }
    
    /// Clear all selected apps
    func clearApps() {
        DispatchQueue.main.async {
            self.selectedApps.removeAll()
        }
    }
    
    /// Build command arguments based on current state
    func buildCommandArguments() -> [String] {
        var args = selectedApps.map { $0.path }
        
        if !steamUserId.isEmpty {
            args.append("--user")
            args.append(steamUserId)
        }
        
        args.append("--size")
        args.append(String(Int(iconSize)))
        
        if isOverwrite {
            args.append("--overwrite")
        }
        
        if isNewVdf {
            args.append("--new-vdf")
        }
        
        if isClearCache {
            args.append("--clear-cache")
        }
        
        if isDebug {
            args.append("--debug")
        }
        
        return args
    }
    
    /// Update the processing status and log output
    func updateProcessingState(isProcessing: Bool, status: String, logOutput: String = "") {
        DispatchQueue.main.async {
            self.isProcessing = isProcessing
            self.status = status
            if !logOutput.isEmpty {
                self.logOutput = logOutput
            }
        }
    }
} 