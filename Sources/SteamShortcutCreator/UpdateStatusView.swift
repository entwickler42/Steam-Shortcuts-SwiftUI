import SwiftUI

/// View for displaying repository update status
struct UpdateStatusView: View {
    @EnvironmentObject var gitRepository: GitRepository
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            RepoStatusDisplay()
            UpdateControlButtons()
        }
        .padding(12)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
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