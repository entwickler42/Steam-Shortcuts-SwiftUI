import SwiftUI

/// View for displaying repository update status
struct UpdateStatusView: View {
    @EnvironmentObject var gitRepository: GitRepository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Repository Status")
                    .font(.headline)
                Spacer()
                
                // Add buttons for opening repository and script
                Button(action: {
                    gitRepository.openInFinder()
                }) {
                    Label("Open Repo", systemImage: "folder")
                }
                .help("Open repository folder in Finder")
                
                Button(action: {
                    gitRepository.openPythonScriptInEditor()
                }) {
                    Label("Open Script", systemImage: "doc.text")
                }
                .help("Open Python script in default editor")
                
                Button(action: {
                    Task {
                        await gitRepository.updateRepository()
                    }
                }) {
                    Label("Update", systemImage: "arrow.clockwise")
                }
                .disabled(gitRepository.isUpdating)
                .help("Update repository from GitHub")
            }
            
            HStack {
                Image(systemName: gitRepository.hasGitError ? "exclamationmark.triangle" : 
                                 gitRepository.isUpdated ? "checkmark.circle" : "clock")
                    .foregroundColor(gitRepository.hasGitError ? .red : 
                                     gitRepository.isUpdated ? .green : .orange)
                
                Text(gitRepository.updateStatus)
                    .foregroundColor(gitRepository.hasGitError ? .red : .primary)
                
                Spacer()
                
                if let lastUpdate = gitRepository.lastUpdateTime {
                    Text("Last updated: \(lastUpdate, formatter: dateFormatter)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if gitRepository.isUpdating {
                ProgressView()
                    .progressViewStyle(LinearProgressViewStyle())
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

/// Display component for repository status
struct RepoStatusDisplay: View {
    @EnvironmentObject var gitRepository: GitRepository
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "arrow.down.circle")
                Text("Repository Status")
                    .fontWeight(.semibold)
            }
            
            Text(gitRepository.updateStatus)
                .font(.caption)
                .foregroundColor(gitRepository.hasGitError ? .red : .secondary)
            
            if let lastUpdate = gitRepository.lastUpdateTime {
                Text("Last updated: \(formattedDate(lastUpdate))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

/// Control buttons for repository updates
struct UpdateControlButtons: View {
    @EnvironmentObject var gitRepository: GitRepository
    
    var body: some View {
        HStack {
            Spacer()
            
            Button(action: {
                Task {
                    await gitRepository.updateRepository()
                }
            }) {
                HStack {
                    if gitRepository.isUpdating {
                        ProgressView()
                            .controlSize(.small)
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    Text("Update")
                }
            }
            .disabled(gitRepository.isUpdating)
            .controlSize(.small)
        }
        .padding(.top, 8)
    }
} 