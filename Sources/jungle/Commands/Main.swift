import ArgumentParser

@main
struct Jungle: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "jungle",
        abstract: "SwiftPM and Cocoapods based projects complexity analyzer.",
        version: "2.3.2",
        subcommands: [HistoryCommand.self, CompareCommand.self, GraphCommand.self, ModulesCommand.self, DependantCommand.self],
        defaultSubcommand: CompareCommand.self
    )
}
