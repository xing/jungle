import ArgumentParser

@main struct DependencyStats: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "DependencyStats",
        abstract: "Displays dependency statistics",
        version: "1.0.0",
        subcommands: [HistoryCommand.self, CompareCommand.self, GraphCommand.self],
        defaultSubcommand: CompareCommand.self
    )
}
