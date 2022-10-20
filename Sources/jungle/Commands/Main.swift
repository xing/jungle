import ArgumentParser

@main
struct Jungle: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "jungle",
        abstract: "Displays dependency statistics",
        version: "1.0.1",
        subcommands: [HistoryCommand.self, CompareCommand.self, GraphCommand.self],
        defaultSubcommand: CompareCommand.self
    )
}
