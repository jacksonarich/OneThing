import CustomDump
import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import StructuredQueries
import Testing

import AppDatabase
@testable import Dashboard
import ModelActions
import AppModels
import Utilities
import TestSupport

class Example {
  @Dependency(\.modelActions) var modelActions
  
  func whatDayIsIt() -> Date {
    @Dependency(\.date) var date
    return date.now
  }
  
  func createTodo(list listID: TodoList.ID) throws {
    let draft = Todo.Draft(rank: "0", listID: listID)
    try modelActions.createTodo(draft)
  }
}

struct TestTests {
  @Test func test() throws {
    let model = try prepareTest {
      TodoListData()
    } model: {
      Example()
    }
    try model.createTodo(list: 1)
    
    try withDependencies(from: model) {
      @Dependency(\.defaultDatabase) var database
      try database.read { db in
        let count = try Todo.count().fetchOne(db)
        #expect(count == 1)
      }
    }
  }
}

@MainActor
struct DashboardTests {
  
  @Test(arguments: [false, true])
  func testListRowTapped(isEditing: Bool) async throws {
    let model = try prepareTest {
      TodoListData()
    } model: {
      DashboardModel(isEditing: isEditing)
    }
    model.listRowTapped(id: 1)
    #expect(model.editingListID == (isEditing ? 1 : nil))
    expectNoDifference(model.navPath, isEditing ? [] : [.listDetail(1)])
  }
  
//  @Test
//  func testListCellTapped() async throws {
//    // setup
//    try ModelActions.testValue.seedDatabase([
//      TodoList.Draft()
//    ], [
//      Todo.Draft(rank: "0", listID: 1)
//    ])
//    // tap "In Progress"
//    let m = DashboardModel()
//    m.listCellTapped(list: .inProgress)
//    expectNoDifference(m.navPath, [.computedListDetail(.inProgress)])
//  }
//  
//  @Test
//  func testListVisibilityChanged() async throws {
//    // setup
//    try ModelActions.testValue.seedDatabase([
//      TodoList.Draft()
//    ], [
//      Todo.Draft(rank: "0", listID: 1)
//    ])
//    let model = DashboardModel()
//    // true -> false
//    model.listVisibilityChanged(list: .inProgress, to: false)
//    expectNoDifference(model.hiddenLists, [.inProgress])
//    // false -> false
//    model.listVisibilityChanged(list: .inProgress, to: false)
//    expectNoDifference(model.hiddenLists, [.inProgress])
//    // false -> true
//    model.listVisibilityChanged(list: .inProgress, to: true)
//    expectNoDifference(model.hiddenLists, [])
//    // true -> true
//    model.listVisibilityChanged(list: .inProgress, to: true)
//    expectNoDifference(model.hiddenLists, [])
//  }
}
