import Foundation

/// The JSON contract currently written by the Flutter Todo model.
/// This probe only decodes the contract; it never rewrites production tasks.
struct TsubusuStoredTodo: Decodable, Equatable {
  let id: String
  let text: String
  let isCompleted: Bool
  let parentId: String?
}

struct TsubusuTaskStorageSnapshot: Equatable {
  let listID: String
  let todos: [TsubusuStoredTodo]
}

struct TsubusuStorageProbeRecord: Codable, Equatable {
  let id: String
  let observedListID: String
  let observedTaskCount: Int
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
/// passing keys to shared_preferences_foundation. The production task keys are
/// read-only here. Probe writes use an isolated key so this discovery code
/// cannot race with Flutter's whole-list persistence or alter user tasks.
struct TsubusuTaskStorage {
  static let lastActiveListIDKey = "flutter.last_active_list_id"
  static let todosListKeyPrefix = "flutter.todos_list_"
  static let probeRecordKey = "flutter.app_intents_storage_probe"

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
  func writeProbeRecord(id: String = UUID().uuidString) throws -> TsubusuStorageProbeRecord {
    let snapshot = try loadActiveSnapshot()
    let record = TsubusuStorageProbeRecord(
      id: id,
      observedListID: snapshot.listID,
      observedTaskCount: snapshot.todos.count
    )

    do {
      let data = try JSONEncoder().encode(record)
      guard let encodedRecord = String(data: data, encoding: .utf8) else {
        throw TsubusuTaskStorageError.invalidTaskData("The probe record is not UTF-8.")
      }
      defaults.set(encodedRecord, forKey: Self.probeRecordKey)
      return record
    } catch let error as TsubusuTaskStorageError {
      throw error
    } catch {
      throw TsubusuTaskStorageError.invalidTaskData(error.localizedDescription)
    }
  }
}
