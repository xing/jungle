import ArgumentParser

@main
struct Jungle: AsyncParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "jungle",
        abstract: "Displays dependency statistics",
        version: "1.0.0",
        subcommands: [HistoryCommand.self, CompareCommand.self, GraphCommand.self, SPMCommand.self],
        defaultSubcommand: CompareCommand.self
    )
}
