import ArgumentParser

@main
struct Jungle: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "jungle",
        abstract: "SwiftPM and Cocoapods based projects complexity analyzer.",
        version: "2.0.0",
        subcommands: [HistoryCommand.self, CompareCommand.self, GraphCommand.self],
        defaultSubcommand: CompareCommand.self
    )
}
