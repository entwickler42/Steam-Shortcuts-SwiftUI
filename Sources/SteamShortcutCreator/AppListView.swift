import SwiftUI
import UniformTypeIdentifiers

/// View for displaying the list of selected apps
struct AppListView: View {
    @EnvironmentObject var appState: AppState
    @State private var isTargeted = false
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Selected Applications")
                .font(.headline)
                .padding(.bottom, 4)
            
            if appState.selectedApps.isEmpty {
                dropTargetView
            } else {
                appListContainerView
            }
            
            controlButtonsView
        }
        .padding()
    }
    
    // Empty drop target view when no apps are selected
    private var dropTargetView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.secondary.opacity(isTargeted ? 0.2 : 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.blue.opacity(isTargeted ? 0.5 : 0), lineWidth: 2)
                )
            
            VStack(spacing: 12) {
                Image(systemName: "apps.card.bundle")
                    .font(.system(size: 32))
                    .foregroundColor(.secondary)
                Text("Drag .app files here or click Add...")
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .frame(height: 120)
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { items in
            handleDrop(items: items)
        }
    }
    
    // Container view for the app list when apps are selected
    private var appListContainerView: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 2) {
                ForEach(appState.selectedApps) { app in
                    AppRow(app: app)
                }
            }
        }
        .frame(maxHeight: 200)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .onDrop(of: [UTType.fileURL], isTargeted: $isTargeted) { items in
            handleDrop(items: items)
        }
    }
    
    // Control buttons view
    private var controlButtonsView: some View {
        HStack(spacing: 16) {
            Button(action: {
                openFilePanel()
            }) {
                Label("Add...", systemImage: "plus")
            }
            
            Button(action: {
                appState.clearApps()
            }) {
                Label("Clear All", systemImage: "trash")
            }
            .disabled(appState.selectedApps.isEmpty)
        }
        .padding(.top, 8)
    }
    
    // Handle drop of items
    private func handleDrop(items: [NSItemProvider]) -> Bool {
        var isHandled = false
        
        for item in items {
            let _ = item.loadObject(ofClass: URL.self) { url, error in
                if let url = url, error == nil, url.pathExtension == "app" {
                    self.appState.addApp(url: url)
                    isHandled = true
                }
            }
        }
        
        return true
    }
    
    // Open file panel for selecting apps
    private func openFilePanel() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [UTType.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        
        if panel.runModal() == .OK {
            for url in panel.urls {
                appState.addApp(url: url)
            }
        }
    }
}

/// Row for displaying a single app
struct AppRow: View {
    @EnvironmentObject var appState: AppState
    let app: MacOSApp
    
    var body: some View {
        HStack {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            } else {
                Image(systemName: "app.dashed")
                    .font(.system(size: 24))
                    .frame(width: 32, height: 32)
            }
            
            VStack(alignment: .leading) {
                Text(app.name)
                    .fontWeight(.medium)
                Text(app.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Button(action: {
                appState.removeApp(app: app)
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 8)
    }
} 