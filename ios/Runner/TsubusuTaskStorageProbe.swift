import Foundation

/// The JSON contract currently written by the Flutter Todo model.
struct TsubusuStoredTodo: Codable, Equatable {
  var id: String
  var text: String
  var isCompleted: Bool
  var parentId: String?
}

struct TsubusuTaskStorageSnapshot: Equatable {
  let listID: String
  var todos: [TsubusuStoredTodo]
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
  case emptyTaskText
  case taskNotFound(String)
  case ambiguousTask(String, [String])

  var errorDescription: String? {
    switch self {
    case .noActiveList:
      return "No active Tsubusu task list was found. Open Tsubusu once and try again."
    case .missingTaskData(let key):
      return "No task data was found for the active list (key: \(key))."
    case .invalidTaskData(let reason):
      return "The active Tsubusu task data is invalid: \(reason)"
    case .emptyTaskText:
      return "The task text cannot be empty."
    case .taskNotFound(let query):
      return "No task matched \"\(query)\"."
    case .ambiguousTask(let query, let matches):
      return "More than one task matched \"\(query)\": \(matches.joined(separator: ", ")). Use a task ID."
    }
  }
}

/// An adapter for the storage contract shared with Dart.
///
/// The legacy shared_preferences Dart API applies the `flutter.` prefix before
/// passing keys to shared_preferences_foundation.
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

  func addTask(text: String, id: String = UUID().uuidString) throws -> TsubusuStoredTodo {
    let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !normalizedText.isEmpty else {
      throw TsubusuTaskStorageError.emptyTaskText
    }

    var snapshot = try loadActiveSnapshot()
    let todo = TsubusuStoredTodo(id: id, text: normalizedText, isCompleted: false, parentId: nil)
    snapshot.todos.append(todo)
    try save(snapshot)
    return todo
  }

  func completeTask(matching query: String) throws -> TsubusuStoredTodo {
    var snapshot = try loadActiveSnapshot()
    let index = try taskIndex(matching: query, in: snapshot.todos)
    let taskID = snapshot.todos[index].id

    for index in snapshot.todos.indices where snapshot.todos[index].id == taskID || isDescendant(snapshot.todos[index], of: taskID, in: snapshot.todos) {
      snapshot.todos[index].isCompleted = true
    }
    var parentID = snapshot.todos[index].parentId
    var visited: Set<String> = []
    while let currentParentID = parentID, visited.insert(currentParentID).inserted {
      guard let parentIndex = snapshot.todos.firstIndex(where: { $0.id == currentParentID }) else {
        break
      }
      let children = snapshot.todos.filter { $0.parentId == currentParentID }
      snapshot.todos[parentIndex].isCompleted = !children.isEmpty && children.allSatisfy(\.isCompleted)
      parentID = snapshot.todos[parentIndex].parentId
    }
    try save(snapshot)
    return snapshot.todos[index]
  }

  func deleteTask(matching query: String) throws -> TsubusuStoredTodo {
    var snapshot = try loadActiveSnapshot()
    let index = try taskIndex(matching: query, in: snapshot.todos)
    let task = snapshot.todos[index]
    var idsToDelete: Set<String> = [task.id]
    var changed = true

    while changed {
      changed = false
      for todo in snapshot.todos where todo.parentId.map(idsToDelete.contains) == true {
        changed = idsToDelete.insert(todo.id).inserted || changed
      }
    }

    snapshot.todos.removeAll { idsToDelete.contains($0.id) }
    try save(snapshot)
    return task
  }

  func taskIndex(matching query: String, in todos: [TsubusuStoredTodo]) throws -> Int {
    let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
    if let idIndex = todos.firstIndex(where: { $0.id == normalizedQuery }) {
      return idIndex
    }

    let matches = todos.enumerated().filter {
      $0.element.text.compare(normalizedQuery, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame
    }
    guard !matches.isEmpty else {
      throw TsubusuTaskStorageError.taskNotFound(normalizedQuery)
    }
    guard matches.count == 1 else {
      throw TsubusuTaskStorageError.ambiguousTask(normalizedQuery, matches.map { $0.element.id })
    }
    return matches[0].offset
  }

  private func save(_ snapshot: TsubusuTaskStorageSnapshot) throws {
    let key = Self.todosListKeyPrefix + snapshot.listID
    do {
      let data = try JSONEncoder().encode(snapshot.todos)
      guard let encodedTodos = String(data: data, encoding: .utf8) else {
        throw TsubusuTaskStorageError.invalidTaskData("The task data is not UTF-8.")
      }
      defaults.set(encodedTodos, forKey: key)
    } catch let error as TsubusuTaskStorageError {
      throw error
    } catch {
      throw TsubusuTaskStorageError.invalidTaskData(error.localizedDescription)
    }
  }

  private func isDescendant(_ todo: TsubusuStoredTodo, of ancestorID: String, in todos: [TsubusuStoredTodo]) -> Bool {
    var parentID = todo.parentId
    var visited: Set<String> = []
    while let currentParentID = parentID, visited.insert(currentParentID).inserted {
      if currentParentID == ancestorID {
        return true
      }
      parentID = todos.first(where: { $0.id == currentParentID })?.parentId
    }
    return false
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
