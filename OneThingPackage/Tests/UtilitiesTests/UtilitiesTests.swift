import CustomDump
import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import Testing

import AppDatabase
import AppModels
import Utilities


let now = Date(timeIntervalSince1970: 0)


@Suite(
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.uuid, .incrementing),
  .dependency(\.date.now, now)
)
struct UtilitiesTests {
  
  @Test
  func testTodoPreset() async throws {
    let t1 = Todo.Draft(
      rank: "0",
      listID: 1
    )
    let t2 = Todo.Draft(
      id: nil,
      title: "",
      notes: "",
      deadline: nil,
      frequencyUnit: nil,
      frequencyCount: nil,
      createDate: now,
      modifyDate: now,
      completeDate: nil,
      deleteDate: nil,
      rank: "0",
      listID: 1
    )
    expectNoDifference(t2, t1)
  }
  
  @Test
  func testTodoListPreset() async throws {
    let l1 = TodoList.Draft.preset()
    let l2 = TodoList.Draft(
      id: nil,
      name: "",
      color: .red,
      createDate: now,
      modifyDate: now
    )
    expectNoDifference(l2, l1)
  }
  
  @Test
  func testTodoSearch() async throws {
    let t1 = Todo.Draft(
      title: "Bell pepper",
      rank: "0",
      listID: 1
    )
    #expect(t1.search(""))
    #expect(t1.search(" "))
    #expect(t1.search("bell"))
    #expect(t1.search("PEPPER"))
    #expect(!t1.search("  "))
    #expect(!t1.search("banana"))
    let t2 = Todo.Draft(
      title: "",
      rank: "0",
      listID: 1
    )
    #expect(t2.search(""))
    #expect(!t2.search("x"))
  }
}
