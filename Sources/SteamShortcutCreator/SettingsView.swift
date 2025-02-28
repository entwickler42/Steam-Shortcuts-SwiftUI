import SwiftUI

/// Simple structure to hold Steam user information
struct SteamUserInfo: Identifiable, Hashable {
    let id: String
    let name: String
    
    var displayName: String {
        return name.isEmpty ? "User \(id)" : "\(name) (\(id))"
    }
}

/// View for configuring app settings
struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var steamDirectoryExists = false
    @State private var detectedUsers: [SteamUserInfo] = []
    @State private var isLoadingUsers = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Settings")
                .font(.headline)
                .padding(.bottom, 2)
            
            // Steam User Selection
            HStack(spacing: 8) {
                Text("Steam User:")
                    .frame(width: 80, alignment: .leading)
                
                if isLoadingUsers {
                    ProgressView()
                        .frame(width: 30)
                } else if !detectedUsers.isEmpty {
                    // If we have users, show a picker
                    Picker("Select User", selection: $appState.steamUserId) {
                        Text("Default").tag("")
                        ForEach(detectedUsers) { user in
                            Text(user.displayName).tag(user.id)
                        }
                    }
                    .labelsHidden()
                    .frame(minWidth: 240)
                } else {
                    // Otherwise show a text field
                    TextField("Enter Steam User ID", text: $appState.steamUserId)
                        .frame(width: 180)
                }
                
                Spacer()
                
                if !steamDirectoryExists {
                    Text("Steam not found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    Task { await findSteamUsers() }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .help("Look for Steam users")
            }
            
            // Icon Size
            HStack(spacing: 8) {
                Text("Icon Size:")
                    .frame(width: 80, alignment: .leading)
                Slider(value: $appState.iconSize, in: 64...512, step: 64)
                    .frame(width: 180)
                Text("\(Int(appState.iconSize))px")
                    .frame(width: 50)
                Spacer()
            }
            
            // Options in a more compact layout
            HStack(alignment: .top, spacing: 8) {
                Text("Options:")
                    .frame(width: 80, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Toggle("Overwrite existing shortcuts", isOn: $appState.isOverwrite)
                    Toggle("Create new shortcuts.vdf file", isOn: $appState.isNewVdf)
                    Toggle("Clear Steam's HTTP cache", isOn: $appState.isClearCache)
                    Toggle("Show debug information", isOn: $appState.isDebug)
                }
                .toggleStyle(.checkbox)
                .font(.callout)
                
                Spacer()
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
        .onAppear {
            Task { await findSteamUsers() }
        }
    }
    
    // Simple function to look for Steam users and extract their names
    private func findSteamUsers() async {
        isLoadingUsers = true
        detectedUsers = []
        
        // Get the user's home directory
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let steamPath = homeDirectory.appendingPathComponent("Library/Application Support/Steam")
        let userdataPath = steamPath.appendingPathComponent("userdata")
        
        // Check if Steam directory exists
        steamDirectoryExists = FileManager.default.fileExists(atPath: steamPath.path)
        
        if steamDirectoryExists {
            do {
                // Check if userdata directory exists
                if FileManager.default.fileExists(atPath: userdataPath.path) {
                    // Get directories in userdata
                    let contents = try FileManager.default.contentsOfDirectory(atPath: userdataPath.path)
                    
                    // Parse user directories
                    var users: [SteamUserInfo] = []
                    
                    for userId in contents {
                        // Only consider directories with numeric names
                        let userDirPath = userdataPath.appendingPathComponent(userId)
                        let isDirectory = (try? FileManager.default.attributesOfItem(
                            atPath: userDirPath.path
                        )[.type] as? FileAttributeType) == .typeDirectory
                        
                        if isDirectory && userId.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
                            // Try to get the localconfig.vdf file
                            let configPath = userDirPath.appendingPathComponent("config/localconfig.vdf")
                            var userName = ""
                            
                            if FileManager.default.fileExists(atPath: configPath.path),
                               let configData = try? String(contentsOf: configPath, encoding: .utf8) {
                                // Extract PersonaName from config
                                userName = extractPersonaName(from: configData) ?? ""
                            }
                            
                            users.append(SteamUserInfo(id: userId, name: userName))
                        }
                    }
                    
                    await MainActor.run {
                        self.detectedUsers = users.sorted { 
                            // Sort by name first, then by ID
                            if $0.name.isEmpty && !$1.name.isEmpty {
                                return false
                            } else if !$0.name.isEmpty && $1.name.isEmpty {
                                return true
                            } else if !$0.name.isEmpty && !$1.name.isEmpty {
                                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                            } else {
                                return $0.id < $1.id
                            }
                        }
                    }
                }
            } catch {
                print("Error finding Steam users: \(error)")
            }
        }
        
        isLoadingUsers = false
    }
    
    // Extract the PersonaName from the localconfig.vdf file
    private func extractPersonaName(from content: String) -> String? {
        // Look for "PersonaName"    "value" pattern (VDF format)
        let pattern = #""PersonaName"\s+"([^"]+)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let range = NSRange(content.startIndex..., in: content)
        if let match = regex.firstMatch(in: content, options: [], range: range),
           match.numberOfRanges > 1 {
            let valueRange = match.range(at: 1)
            if let range = Range(valueRange, in: content) {
                return String(content[range])
            }
        }
        
        return nil
    }
} 