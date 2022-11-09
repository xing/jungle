import ArgumentParser

@main
struct Jungle: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "jungle",
        abstract: "Cocoapods and SPM projects Complexity metrics",
        version: "1.1.0",
        subcommands: [HistoryCommand.self, CompareCommand.self, GraphCommand.self],
        defaultSubcommand: CompareCommand.self
    )
}
