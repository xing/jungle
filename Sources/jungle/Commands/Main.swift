import ArgumentParser

@main
struct Jungle: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "jungle",
        abstract: "SwiftPM and Cocoapods based projects complexity analyzer.",
        version: "2.1.0",
        subcommands: [HistoryCommand.self, CompareCommand.self, GraphCommand.self, ModulesCommand.self],
        defaultSubcommand: CompareCommand.self
    )
}
