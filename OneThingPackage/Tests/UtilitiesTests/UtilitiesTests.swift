import CustomDump
import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

import AppDatabase
import Schema
import Utilities


@Suite(
  .dependency(\.continuousClock, ImmediateClock()),
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.uuid, .incrementing),
  .dependency(\.date.now, Date(timeIntervalSince1970: 0))
)
struct UtilitiesTests {
  
  @Test
  func testTodoPreset() async throws {
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
    expectNoDifference(t1, t2)
  }
  
  @Test
  func testTodoListPreset() async throws {
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
  
  @Test
  func testTodoSearch() async throws {
    let t1 = Todo.Draft.preset(title: "Bell pepper", order: "", listID: 1)
    #expect(t1.search(""))
    #expect(t1.search(" "))
    #expect(t1.search("bell"))
    #expect(t1.search("PEPPER"))
    #expect(!t1.search("  "))
    #expect(!t1.search("banana"))
    let t2 = Todo.Draft.preset(title: "", order: "", listID: 1)
    #expect(t2.search(""))
    #expect(!t2.search("x"))
  }
}
