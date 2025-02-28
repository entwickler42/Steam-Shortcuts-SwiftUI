import SwiftUI

/// View for displaying status and logs
struct StatusView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Status")
                .font(.headline)
            
            StatusIndicatorView()
            
            Text("Log Output")
                .font(.subheadline)
            
            LogOutputView()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }
}

/// Status indicator showing current processing state
struct StatusIndicatorView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(appState.status)
                .font(.subheadline)
                .foregroundColor(statusColor)
            Spacer()
            
            if appState.isProcessing {
                ProgressView()
                    .controlSize(.small)
                    .scaleEffect(0.7)
                    .padding(.trailing, 4)
            }
        }
        .padding(.bottom, 8)
    }
    
    private var statusColor: Color {
        if appState.isProcessing {
            return .blue
        } else if appState.logOutput.contains("Error:") {
            return .red
        } else if appState.logOutput.contains("Successfully created") {
            return .green
        } else {
            return .primary
        }
    }
}

/// Scrollable view to display log output
struct LogOutputView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            ScrollViewReader { proxy in
                Text(appState.logOutput.isEmpty ? "No output to display" : appState.logOutput)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .id("logEnd")
                    .onChange(of: appState.logOutput) { _ in
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo("logEnd", anchor: .bottom)
                            }
                        }
                    }
            }
        }
        .frame(height: 150)
        .background(Color.black.opacity(0.1))
        .cornerRadius(4)
    }
} 