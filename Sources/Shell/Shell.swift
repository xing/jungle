import Foundation

@discardableResult public func shell(_ command: String, at directory: URL? = nil, skipErrorsOutput: Bool = true) throws -> String {
    let task = Process()
    let pipe = Pipe()
    
    let errorPipe = Pipe()

    if !skipErrorsOutput {
        task.standardError = pipe
    } else {
        task.standardError = errorPipe
    }
    task.standardOutput = pipe
    task.arguments = ["--login", "-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    if let directory = directory {
        task.currentDirectoryURL = directory
    }
    
    try task.run()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    
    return output
}
