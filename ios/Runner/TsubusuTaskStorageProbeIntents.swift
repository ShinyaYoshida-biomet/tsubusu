import AppIntents

// The Runner target excludes this file from Profile and Release builds. These
// shortcuts are diagnostics for the storage discovery only and must not ship.
@available(iOS 16.0, *)
struct TsubusuReadTaskStorageIntent: AppIntent {
  static var title: LocalizedStringResource = "Read Tsubusu task storage"

  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let snapshot = try TsubusuTaskStorage().loadActiveSnapshot()
    let result = "The active list contains \(snapshot.todos.count) tasks."
    return .result(value: result)
  }
}

@available(iOS 16.0, *)
struct TsubusuWriteTaskStorageProbeIntent: AppIntent {
  static var title: LocalizedStringResource = "Write a Tsubusu storage probe"

  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let record = try TsubusuTaskStorage().writeProbeRecord()
    return .result(value: "Stored probe \(record.id) without changing any tasks.")
  }
}

@available(iOS 16.0, *)
struct TsubusuAppShortcuts: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    AppShortcut(
      intent: TsubusuReadTaskStorageIntent(),
      phrases: ["Read task storage in \(.applicationName)"]
    )
    AppShortcut(
      intent: TsubusuWriteTaskStorageProbeIntent(),
      phrases: ["Write a storage probe in \(.applicationName)"]
    )
  }
}
