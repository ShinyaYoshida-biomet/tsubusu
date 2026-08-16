import AppIntents

@available(iOS 16.0, *)
struct TsubusuReadTaskStorageIntent: AppIntent {
  static var title: LocalizedStringResource = "Read Tsubusu task storage"

  func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
    let snapshot = try TsubusuTaskStorage().loadActiveSnapshot()
    let result = "The active list contains \(snapshot.todos.count) tasks."
    return .result(value: result, dialog: IntentDialog(stringLiteral: result))
  }
}

@available(iOS 16.0, *)
struct TsubusuWriteTaskStorageProbeIntent: AppIntent {
  static var title: LocalizedStringResource = "Write a Tsubusu storage probe"

  func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
    let record = try TsubusuTaskStorage().writeProbeRecord()
    let result = "Stored probe \(record.id) without changing any tasks."
    return .result(value: result, dialog: IntentDialog(stringLiteral: result))
  }
}

@available(iOS 16.0, *)
struct TsubusuAddTaskIntent: AppIntent {
  static var title: LocalizedStringResource = "Add a Tsubusu task"

  @Parameter(title: "Task text")
  var text: String

  func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
    let todo = try TsubusuTaskStorage().addTask(text: text)
    let result = "Added task: \(todo.text)."
    return .result(value: result, dialog: IntentDialog(stringLiteral: result))
  }
}

@available(iOS 16.0, *)
struct TsubusuListTasksIntent: AppIntent {
  static var title: LocalizedStringResource = "List Tsubusu tasks"

  func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
    let snapshot = try TsubusuTaskStorage().loadActiveSnapshot()
    let result = snapshot.todos.isEmpty
      ? "The active task list is empty."
      : snapshot.todos.map { "\($0.isCompleted ? "Completed" : "Open"): \($0.text) [\($0.id)]" }.joined(separator: "\n")
    return .result(value: result, dialog: IntentDialog(stringLiteral: result))
  }
}

@available(iOS 16.0, *)
struct TsubusuCompleteTaskIntent: AppIntent {
  static var title: LocalizedStringResource = "Complete a Tsubusu task"

  @Parameter(title: "Task ID or exact text")
  var task: String

  func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
    let todo = try TsubusuTaskStorage().completeTask(matching: task)
    let result = "Completed task: \(todo.text)."
    return .result(value: result, dialog: IntentDialog(stringLiteral: result))
  }
}

@available(iOS 16.0, *)
struct TsubusuDeleteTaskIntent: AppIntent {
  static var title: LocalizedStringResource = "Delete a Tsubusu task"

  @Parameter(title: "Task ID or exact text")
  var task: String

  func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<String> {
    let storage = TsubusuTaskStorage()
    let snapshot = try storage.loadActiveSnapshot()
    let index = try storage.taskIndex(matching: task, in: snapshot.todos)
    let todo = snapshot.todos[index]
    try await requestConfirmation()
    let deleted = try storage.deleteTask(matching: todo.id)
    let result = "Deleted task: \(deleted.text)."
    return .result(value: result, dialog: IntentDialog(stringLiteral: result))
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
      intent: TsubusuAddTaskIntent(),
      phrases: ["Add a task to \(.applicationName)"]
    )
    AppShortcut(
      intent: TsubusuListTasksIntent(),
      phrases: ["List tasks in \(.applicationName)"]
    )
    AppShortcut(
      intent: TsubusuCompleteTaskIntent(),
      phrases: ["Complete a task in \(.applicationName)"]
    )
    AppShortcut(
      intent: TsubusuDeleteTaskIntent(),
      phrases: ["Delete a task in \(.applicationName)"]
    )
  }
}
