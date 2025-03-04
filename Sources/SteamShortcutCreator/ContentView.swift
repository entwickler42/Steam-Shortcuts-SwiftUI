import SwiftUI

/// Main content view for the application
struct ContentView: View {
    @StateObject private var gitRepository = GitRepository()
    @StateObject private var appState = AppState()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header with logo
                headerView
                
                // Update status
                UpdateStatusView()
                    .environmentObject(gitRepository)
                
                // App selection
                AppListView()
                    .environmentObject(appState)
                
                // Settings
                SettingsView()
                    .environmentObject(appState)
                
                // Status and logs
                StatusView()
                    .environmentObject(appState)
                
                // Create button
                createButtonView
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 500)
        .environmentObject(gitRepository)
        .environmentObject(appState)
        .onAppear {
            // Check for repository updates when app launches
            Task {
                await gitRepository.updateRepository()
            }
        }
    }
    
    private var headerView: some View {
        HStack {
            Image(systemName: "gamecontroller.fill")
                .font(.largeTitle)
                .foregroundColor(.blue)
            VStack(alignment: .leading) {
                Text("Steam Shortcut Creator")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Add macOS applications to Steam with proper icons")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    private var createButtonView: some View {
        HStack {
            Spacer()
            Button(action: {
                Task {
                    await createShortcuts()
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Create Shortcuts")
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 4)
            }
            .keyboardShortcut(.defaultAction)
            .disabled(appState.selectedApps.isEmpty || appState.isProcessing)
        }
    }
    
    /// Create shortcuts by running the Python script
    func createShortcuts() async {
        guard !appState.selectedApps.isEmpty else { return }
        
        appState.updateProcessingState(isProcessing: true, status: "Processing...", logOutput: "")
        
        do {
            // First check if repository is updated
            if !gitRepository.isUpdated {
                appState.updateProcessingState(isProcessing: true, status: "Updating repository...", logOutput: "Repository needs to be updated before running the script.")
                await gitRepository.updateRepository()
                
                if gitRepository.hasGitError {
                    appState.updateProcessingState(isProcessing: false, status: "Repository update failed", logOutput: "Failed to update repository: \(gitRepository.updateStatus)")
                    return
                }
            }
            
            let args = appState.buildCommandArguments()
            let pythonRunner = PythonRunner(gitRepository: gitRepository)
            
            appState.updateProcessingState(isProcessing: true, status: "Setting up Python environment...", logOutput: "")
            let output = try await pythonRunner.runPythonScript(arguments: args)
            
            if output.contains("Error:") || output.contains("error:") {
                appState.updateProcessingState(isProcessing: false, status: "Completed with errors", logOutput: output)
            } else if output.contains("Successfully created") {
                appState.updateProcessingState(isProcessing: false, status: "Shortcuts created successfully", logOutput: output)
            } else {
                appState.updateProcessingState(isProcessing: false, status: "Completed", logOutput: output)
            }
        } catch {
            appState.updateProcessingState(isProcessing: false, status: "Failed", logOutput: "Error: \(error.localizedDescription)")
        }
    }
} 