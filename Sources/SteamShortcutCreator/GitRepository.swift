import Foundation
import ShellOut

/// GitRepository class responsible for managing Git operations
class GitRepository: ObservableObject {
    private let repoURL = "https://github.com/entwickler42/VDF.git"
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
        localRepoPath = appDir.appendingPathComponent("VDF", isDirectory: true)
        
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
            
            try FileManager.default.createDirectory(at: self.localRepoPath, withIntermediateDirectories: true)
            
            // Escape the path to ensure spaces are handled correctly
            let escapedPath = self.localRepoPath.path.replacingOccurrences(of: " ", with: "\\ ")
            
            try shellOut(to: "git clone \(self.repoURL) \(escapedPath)")
            try shellOut(to: "git", arguments: ["checkout", "main"], at: self.localRepoPath.path)
        }.value
    }
    
    /// Pull latest changes
    private func pullLatestChanges() async throws {
        try await Task.detached { [self] in
            try shellOut(to: "git", arguments: ["fetch"], at: self.localRepoPath.path)
            try shellOut(to: "git", arguments: ["reset", "--hard", "origin/main"], at: self.localRepoPath.path)
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
} 