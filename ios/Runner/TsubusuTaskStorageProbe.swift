import AppIntents
import Foundation

/// The JSON contract currently written by the Flutter Todo model.
struct TsubusuStoredTodo: Codable, Equatable {
  let id: String
  let text: String
  let isCompleted: Bool
  let parentId: String?
}

struct TsubusuTaskStorageSnapshot: Equatable {
  let listID: String
  let todos: [TsubusuStoredTodo]
}

enum TsubusuTaskStorageError: LocalizedError {
  case noActiveList
  case missingTaskData(String)
  case invalidTaskData(String)

  var errorDescription: String? {
    switch self {
    case .noActiveList:
      return "No active Tsubusu task list was found. Open Tsubusu once and try again."
    case .missingTaskData(let key):
      return "No task data was found for the active list (key: \(key))."
    case .invalidTaskData(let reason):
      return "The active Tsubusu task data is invalid: \(reason)"
    }
  }
}

/// A deliberately small adapter for the storage contract shared with Dart.
///
/// The legacy shared_preferences Dart API applies the `flutter.` prefix before
/// passing keys to shared_preferences_foundation. Keeping the constants here
/// explicit makes the interoperability assumption easy to test and review
/// before implementing production CRUD intents.
struct TsubusuTaskStorage {
  static let lastActiveListIDKey = "flutter.last_active_list_id"
  static let todosListKeyPrefix = "flutter.todos_list_"
  static let probeTaskText = "[App Intents probe] storage write verification"

  private let defaults: UserDefaults

  init(defaults: UserDefaults = .standard) {
    self.defaults = defaults
  }

  func loadActiveSnapshot() throws -> TsubusuTaskStorageSnapshot {
    guard let listID = defaults.string(forKey: Self.lastActiveListIDKey),
          !listID.isEmpty else {
      throw TsubusuTaskStorageError.noActiveList
    }

    let key = Self.todosListKeyPrefix + listID
    guard let encodedTodos = defaults.string(forKey: key) else {
      throw TsubusuTaskStorageError.missingTaskData(key)
    }

    guard let data = encodedTodos.data(using: .utf8) else {
      throw TsubusuTaskStorageError.invalidTaskData("The stored value is not UTF-8.")
    }

    do {
      let todos = try JSONDecoder().decode([TsubusuStoredTodo].self, from: data)
      return TsubusuTaskStorageSnapshot(listID: listID, todos: todos)
    } catch {
      throw TsubusuTaskStorageError.invalidTaskData(error.localizedDescription)
    }
  }

  @discardableResult
  func appendProbeTask() throws -> TsubusuStoredTodo {
    let snapshot = try loadActiveSnapshot()
    let task = TsubusuStoredTodo(
      id: String(Int(Date().timeIntervalSince1970 * 1_000_000)),
      text: Self.probeTaskText,
      isCompleted: false,
      parentId: nil
    )
    try save(snapshot.todos + [task], toListID: snapshot.listID)
    return task
  }

  @discardableResult
  func removeProbeTasks() throws -> Int {
    let snapshot = try loadActiveSnapshot()
    let remaining = snapshot.todos.filter { $0.text != Self.probeTaskText }
    let removedCount = snapshot.todos.count - remaining.count
    if removedCount > 0 {
      try save(remaining, toListID: snapshot.listID)
    }
    return removedCount
  }

  private func save(_ todos: [TsubusuStoredTodo], toListID listID: String) throws {
    do {
      let data = try JSONEncoder().encode(todos)
      guard let encodedTodos = String(data: data, encoding: .utf8) else {
        throw TsubusuTaskStorageError.invalidTaskData("The encoded value is not UTF-8.")
      }
      defaults.set(encodedTodos, forKey: Self.todosListKeyPrefix + listID)
    } catch let error as TsubusuTaskStorageError {
      throw error
    } catch {
      throw TsubusuTaskStorageError.invalidTaskData(error.localizedDescription)
    }
  }
}

@available(iOS 16.0, *)
struct TsubusuReadTaskStorageIntent: AppIntent {
  static var title: LocalizedStringResource = "Read Tsubusu task storage"
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let snapshot = try TsubusuTaskStorage().loadActiveSnapshot()
    let result = "Active list \(snapshot.listID) contains \(snapshot.todos.count) tasks."
    return .result(value: result)
  }
}

@available(iOS 16.0, *)
struct TsubusuWriteTaskStorageProbeIntent: AppIntent {
  static var title: LocalizedStringResource = "Write a Tsubusu storage probe"
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let task = try TsubusuTaskStorage().appendProbeTask()
    return .result(value: "Added the probe task with ID \(task.id).")
  }
}

@available(iOS 16.0, *)
struct TsubusuRemoveTaskStorageProbeIntent: AppIntent {
  static var title: LocalizedStringResource = "Remove Tsubusu storage probes"
  static var openAppWhenRun = false

  func perform() async throws -> some IntentResult & ReturnsValue<String> {
    let removedCount = try TsubusuTaskStorage().removeProbeTasks()
    return .result(value: "Removed \(removedCount) probe task(s).")
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
    AppShortcut(
      intent: TsubusuRemoveTaskStorageProbeIntent(),
      phrases: ["Remove storage probes in \(.applicationName)"]
    )
  }
}
