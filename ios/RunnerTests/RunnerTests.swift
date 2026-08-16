import Flutter
import UIKit
import XCTest
@testable import Runner

class RunnerTests: XCTestCase {
  private var suiteName: String!
  private var defaults: UserDefaults!

  override func setUp() {
    super.setUp()
    suiteName = "TsubusuTaskStorageTests.\(UUID().uuidString)"
    defaults = UserDefaults(suiteName: suiteName)
    defaults.removePersistentDomain(forName: suiteName)
  }

  override func tearDown() {
    defaults.removePersistentDomain(forName: suiteName)
    defaults = nil
    suiteName = nil
    super.tearDown()
  }

  func testLoadActiveSnapshotDecodesLegacyTaskWithoutParentID() throws {
    defaults.set("list-1", forKey: TsubusuTaskStorage.lastActiveListIDKey)
    defaults.set(
      #"[{"id":"task-1","text":"Example task","isCompleted":false}]"#,
      forKey: TsubusuTaskStorage.todosListKeyPrefix + "list-1"
    )

    let snapshot = try TsubusuTaskStorage(defaults: defaults).loadActiveSnapshot()

    XCTAssertEqual(snapshot.listID, "list-1")
    XCTAssertEqual(
      snapshot.todos,
      [TsubusuStoredTodo(id: "task-1", text: "Example task", isCompleted: false, parentId: nil)]
    )
  }

  func testLoadActiveSnapshotRequiresAnActiveList() {
    XCTAssertThrowsError(try TsubusuTaskStorage(defaults: defaults).loadActiveSnapshot()) { error in
      guard case TsubusuTaskStorageError.noActiveList = error else {
        return XCTFail("Expected noActiveList, got \(error)")
      }
    }
  }

  func testLoadActiveSnapshotRejectsInvalidJSON() {
    defaults.set("list-1", forKey: TsubusuTaskStorage.lastActiveListIDKey)
    defaults.set("not-json", forKey: TsubusuTaskStorage.todosListKeyPrefix + "list-1")

    XCTAssertThrowsError(try TsubusuTaskStorage(defaults: defaults).loadActiveSnapshot()) { error in
      guard case TsubusuTaskStorageError.invalidTaskData = error else {
        return XCTFail("Expected invalidTaskData, got \(error)")
      }
    }
  }

  func testWriteProbeRecordDoesNotModifyProductionTaskJSON() throws {
    let taskKey = TsubusuTaskStorage.todosListKeyPrefix + "list-1"
    let taskJSON = #"[{"id":"task-1","text":"Example task","isCompleted":false,"futureField":"keep-me"}]"#
    defaults.set("list-1", forKey: TsubusuTaskStorage.lastActiveListIDKey)
    defaults.set(taskJSON, forKey: taskKey)

    let record = try TsubusuTaskStorage(defaults: defaults).writeProbeRecord(id: "probe-1")

    XCTAssertEqual(
      record,
      TsubusuStorageProbeRecord(id: "probe-1", observedListID: "list-1", observedTaskCount: 1)
    )
    XCTAssertEqual(defaults.string(forKey: taskKey), taskJSON)

    let encodedProbe = try XCTUnwrap(defaults.string(forKey: TsubusuTaskStorage.probeRecordKey))
    let decodedProbe = try JSONDecoder().decode(
      TsubusuStorageProbeRecord.self,
      from: try XCTUnwrap(encodedProbe.data(using: .utf8))
    )
    XCTAssertEqual(decodedProbe, record)
  }

  func testAddAndCompleteTaskWritesTheActiveList() throws {
    let taskKey = TsubusuTaskStorage.todosListKeyPrefix + "list-1"
    defaults.set("list-1", forKey: TsubusuTaskStorage.lastActiveListIDKey)
    defaults.set(
      #"[{"id":"parent","text":"Parent","isCompleted":false,"parentId":null},{"id":"child","text":"Child","isCompleted":false,"parentId":"parent"}]"#,
      forKey: taskKey
    )

    let storage = TsubusuTaskStorage(defaults: defaults)
    let added = try storage.addTask(text: "  New task  ", id: "new-task")
    XCTAssertEqual(added, TsubusuStoredTodo(id: "new-task", text: "New task", isCompleted: false, parentId: nil))

    let completed = try storage.completeTask(matching: "parent")
    XCTAssertEqual(completed.id, "parent")

    let snapshot = try storage.loadActiveSnapshot()
    XCTAssertEqual(snapshot.todos.first(where: { $0.id == "parent" })?.isCompleted, true)
    XCTAssertEqual(snapshot.todos.first(where: { $0.id == "child" })?.isCompleted, true)
    XCTAssertEqual(snapshot.todos.first(where: { $0.id == "new-task" })?.isCompleted, false)
  }

  func testDeleteTaskRemovesDescendantsAndRejectsAmbiguousText() throws {
    defaults.set("list-1", forKey: TsubusuTaskStorage.lastActiveListIDKey)
    defaults.set(
      #"[{"id":"parent","text":"Parent","isCompleted":false,"parentId":null},{"id":"child","text":"Child","isCompleted":false,"parentId":"parent"},{"id":"duplicate-1","text":"Same","isCompleted":false,"parentId":null},{"id":"duplicate-2","text":"Same","isCompleted":false,"parentId":null}]"#,
      forKey: TsubusuTaskStorage.todosListKeyPrefix + "list-1"
    )

    let storage = TsubusuTaskStorage(defaults: defaults)
    XCTAssertThrowsError(try storage.deleteTask(matching: "Same")) { error in
      guard case TsubusuTaskStorageError.ambiguousTask = error else {
        return XCTFail("Expected ambiguousTask, got \(error)")
      }
    }

    let deleted = try storage.deleteTask(matching: "parent")
    XCTAssertEqual(deleted.id, "parent")
    XCTAssertEqual(try storage.loadActiveSnapshot().todos.map(\.id), ["duplicate-1", "duplicate-2"])
  }
}
