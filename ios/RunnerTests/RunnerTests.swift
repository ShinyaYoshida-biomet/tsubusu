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
}
