import Foundation
import ShellOut
import AppKit

/// GitRepository class responsible for managing Git operations
class GitRepository: ObservableObject {
    private let repoURL = "https://github.com/entwickler42/Steam-Shortcuts-Python.git"
    private let localRepoPath: URL
    
    @Published var isUpdating: Bool = false
    @Published var lastUpdateTime: Date?
    @Published var updateStatus: String = "Not updated yet"
    @Published var hasGitError: Bool = false
    @Published var isUpdated: Bool = false
    
    // Public accessor for the repo path
    var repoPath: String {
        return localRepoPath.path
    }
    
    init() {
        // Create a directory in Application Support
        let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupportDir.appendingPathComponent("SteamShortcutCreator", isDirectory: true)
        localRepoPath = appDir.appendingPathComponent("Steam-Shortcuts-Python", isDirectory: true)
        
        // Create directory if needed
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
    }
    
    /// Check if repository is already cloned
    private func isRepositoryCloned() -> Bool {
        return FileManager.default.fileExists(atPath: localRepoPath.appendingPathComponent(".git").path)
    }
    
    /// Clone or update the repository
    @MainActor
    func updateRepository() async {
        isUpdating = true
        hasGitError = false
        isUpdated = false
        updateStatus = "Checking for updates..."
        
        do {
            if isRepositoryCloned() {
                updateStatus = "Pulling latest changes..."
                try await pullLatestChanges()
            } else {
                updateStatus = "Cloning repository..."
                try await cloneRepository()
            }
            
            lastUpdateTime = Date()
            isUpdated = true
            updateStatus = "Repository updated successfully"
        } catch {
            hasGitError = true
            updateStatus = "Error: \(error.localizedDescription)"
            print("Git error: \(error)")
        }
        
        isUpdating = false
    }
    
    /// Clone the repository
    private func cloneRepository() async throws {
        try await Task.detached { [self] in
            // Remove if exists but somehow .git is missing
            if FileManager.default.fileExists(atPath: self.localRepoPath.path) {
                try FileManager.default.removeItem(at: self.localRepoPath)
            }
            
            try FileManager.default.createDirectory(at: self.localRepoPath.deletingLastPathComponent(), withIntermediateDirectories: true)
            
            // Use direct git commands with properly quoted paths
            try shellOut(to: "/usr/bin/git clone \(self.repoURL) \"\(self.localRepoPath.path)\"")
            try shellOut(to: "/usr/bin/git -C \"\(self.localRepoPath.path)\" checkout main")
        }.value
    }
    
    /// Pull latest changes
    private func pullLatestChanges() async throws {
        try await Task.detached { [self] in
            // Use direct git commands with properly quoted paths
            try shellOut(to: "/usr/bin/git -C \"\(self.localRepoPath.path)\" fetch")
            try shellOut(to: "/usr/bin/git -C \"\(self.localRepoPath.path)\" reset --hard origin/main")
        }.value
    }
    
    /// Get the path to the Python script
    func getPythonScriptPath() -> String {
        return localRepoPath.appendingPathComponent("steam_macos_shortcut_creator/fixicons.py").path
    }
    
    /// Get the path to the virtual environment activation script
    func getVenvPath() -> String {
        return localRepoPath.appendingPathComponent(".venv/bin/activate").path
    }
    
    /// Get the path to the requirements.txt file
    func getRequirementsPath() -> String {
        return localRepoPath.appendingPathComponent("requirements.txt").path
    }
    
    /// Open the repository folder in Finder
    func openInFinder() {
        NSWorkspace.shared.open(localRepoPath)
    }
    
    /// Open the Python script in the default text editor
    func openPythonScriptInEditor() {
        let scriptPath = getPythonScriptPath()
        if FileManager.default.fileExists(atPath: scriptPath) {
            NSWorkspace.shared.open(URL(fileURLWithPath: scriptPath))
        }
    }
} 