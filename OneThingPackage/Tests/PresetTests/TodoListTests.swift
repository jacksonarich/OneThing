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
struct TodoListTests {

  @Test
  func testPreset() async throws {
    @Dependency(\.date) var date
    let l1 = TodoList.Draft.preset(id: 1)
    let l2 = TodoList.Draft(
      id: 1,
      name: "",
      colorIndex: 0,
      createDate: date.now,
      modifyDate: date.now
    )
    expectNoDifference(l1, l2)
  }
}
