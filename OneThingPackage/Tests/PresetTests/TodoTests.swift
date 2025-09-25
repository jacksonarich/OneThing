import AppDatabase
import CustomDump
import Dependencies
import DependenciesTestSupport
import Foundation
import Presets
import SQLiteData
import Testing

@testable import Schema


@Suite(
  .dependency(\.continuousClock, ImmediateClock()),
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.uuid, .incrementing),
  .dependency(\.date.now, Date(timeIntervalSince1970: 0))
)
struct TodoTests {
  @Test
  func testPreset() async throws {
    @Dependency(\.date) var date
    let t1 = Todo.Draft.preset(id: 1, order: "", listID: 1)
    let t2 = Todo.Draft(
      id: 1,
      title: "",
      notes: "",
      deadline: nil,
      frequencyUnitIndex: nil,
      frequencyCount: nil,
      createDate: date.now,
      modifyDate: date.now,
      completeDate: nil,
      deleteDate: nil,
      order: "",
      listID: 1
    )
    expectNoDifference(t2, t1)
  }
}
