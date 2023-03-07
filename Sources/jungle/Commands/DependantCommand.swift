import Foundation
import ArgumentParser
import Shell
import SPMExtractor
import DependencyModule
import PodExtractor

struct DependantCommand: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "dependant",
        abstract: "Outputs a sorted list of targets that depends on the specified one in target"
    )

    @Option(help: "The target in your Podfile or Package.swift file to be used")
    var target: String
    
    @Flag(help: "Show only Test targets")
    var showOnlyTests: Bool = false
    
    @Argument(help: "Path to the directory where Podfile.lock or Package.swift is located")
    var directoryPath: String = "."
    
    func run() throws {
        let directoryPath = (directoryPath as NSString).expandingTildeInPath
        let directoryURL = URL(fileURLWithPath: directoryPath, isDirectory: true)
    
        // Check when this contains a Package.swift or a Podfile
        if FileManager.default.fileExists(atPath: directoryURL.appendingPathComponent("Package.swift").path) {
            try processPackage(at: directoryURL)
        } else {
            try processPodfile(at: directoryURL)
        }
    }
    
    private func processPackage(at directoryURL: URL) throws {
        let packageRaw = try shell("swift package describe --type json", at: directoryURL)
        let targets = try extractDependantTargets(from: packageRaw, target: target)
        processOutput(for: targets)
    }
    
    private func processPodfile(at directoryURL: URL) throws {
        let podfileLock = try shell("git show HEAD:Podfile.lock", at: directoryURL)
        let allPodfileModules = try extractModulesFromPodfileLock(podfileLock, excludeTests: false)
        let targets = try extractDependantTargets(from: allPodfileModules, for: target)
        processOutput(for: targets)
    }
    
    private func processOutput(for modules: [Module]) {
        let output = Array(Set(modules))
            .filter { showOnlyTests ? $0.type == .test : true }
            .map(\.name)
            .sorted()
            .joined(separator: ", ")
        print(output)
    }
}
