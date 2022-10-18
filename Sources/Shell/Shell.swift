import Foundation

public func shell(_ command: String, at currentDirectoryURL: URL? = nil) throws -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["--login", "-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    if let currentDirectoryURL = currentDirectoryURL {
        task.currentDirectoryURL = currentDirectoryURL
    }
    
    try task.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!
    
    return output
}

