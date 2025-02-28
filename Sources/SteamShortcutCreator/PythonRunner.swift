import Foundation
import ShellOut

/// Class for running Python scripts
class PythonRunner {
    private let gitRepository: GitRepository
    
    init(gitRepository: GitRepository) {
        self.gitRepository = gitRepository
    }
    
    /// Run the Python script with the given arguments
    func runPythonScript(arguments: [String]) async throws -> String {
        return try await Task.detached {
            // Check if Python is installed
            do {
                try shellOut(to: "python3", arguments: ["--version"])
            } catch {
                throw PythonError.pythonNotInstalled
            }
            
            // Get the script path and repository path
            let scriptPath = self.gitRepository.getPythonScriptPath()
            let repoPath = self.gitRepository.repoPath
            
            // Make sure setup.py exists
            let setupPath = "\(repoPath)/setup.py"
            if !FileManager.default.fileExists(atPath: setupPath) {
                print("Warning: setup.py not found at \(setupPath)")
            }
            
            // Prepare the arguments
            let escapedArgs = arguments.map { $0.replacingOccurrences(of: "\"", with: "\\\"") }
                                     .map { "\"\($0)\"" }
                                     .joined(separator: " ")
            
            // Run setup.py first to ensure virtual environment, then run the script
            let command = "cd \(repoPath) && python3 \(setupPath) && python3 \"\(scriptPath)\" \(escapedArgs)"
            
            print("Executing command: \(command)")
            
            // Use Process to capture both stdout and stderr
            let task = Process()
            task.launchPath = "/bin/zsh"
            task.arguments = ["-c", command]
            
            // Set up pipes for capturing output
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            task.standardOutput = outputPipe
            task.standardError = errorPipe
            
            do {
                task.launch()
                task.waitUntilExit()
                
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                
                let output = String(data: outputData, encoding: .utf8) ?? ""
                let error = String(data: errorData, encoding: .utf8) ?? ""
                
                // If the process failed, throw an error
                if task.terminationStatus != 0 {
                    let errorDetails = !error.isEmpty ? error : "Process exited with code \(task.terminationStatus)"
                    throw PythonError.scriptExecutionFailed(errorDetails)
                }
                
                // If there's error output but the process succeeded, include it in the output
                if !error.isEmpty {
                    return output + "\n\nWarnings:\n" + error
                }
                
                return output
            } catch let processError as PythonError {
                throw processError
            } catch {
                throw PythonError.scriptExecutionFailed(error.localizedDescription)
            }
        }.value
    }
}

/// Errors related to Python execution
enum PythonError: Error, LocalizedError {
    case pythonNotInstalled
    case scriptExecutionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .pythonNotInstalled:
            return "Python 3 is not installed on this system. Please install Python 3 to continue."
        case .scriptExecutionFailed(let message):
            return "Failed to execute Python script: \(message)"
        }
    }
}