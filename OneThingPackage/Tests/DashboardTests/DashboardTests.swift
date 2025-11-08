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

public func prepareTest<T: AnyObject>(
  @TodoListBuilder lists: () -> [TodoListData],
  dependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in },
  model: () -> T
) throws -> T {
  return try withDependencies {
    $0.date.now = Date(timeIntervalSince1970: 0)
    $0.defaultDatabase = try appDatabase(data: AppData(lists: lists))
    prepareDependencies(&$0)
  } operation: {
    return model()
  }
}

// Move prepareTest to TestSupport module
// Create `run` helper and put in TestSupport
// func run<Model>(
//   _ model: Model,
//   action: (Model) -> Void,
//   @TodoListBuilder data: () -> [TodoListData]
// )


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

//@MainActor
//@Suite(
////  .dependency(\.continuousClock, ImmediateClock()),
////  .dependency(\.defaultDatabase, try appDatabase()),
////  .dependency(\.uuid, .incrementing),
//  .dependency(\.date.now, Date(timeIntervalSince1970: 0))
//)
//struct DashboardTests {
//  
//  @Test
//  func testDashboardInit() async throws {
//    try prepareTest {
//      TodoListData(...) {
//        
//      }
//    }
//    let m = DashboardModel()
//    #expect(m.isCreatingList == false)
//    #expect(m.editingListID == nil)
//    #expect(m.editMode == .inactive)
//  }
//  
//  @Test
//  func testListRowTapped() async throws {
//    // setup
//    try ModelActions.testValue.seedDatabase([
//      TodoList.Draft()
//    ], [
//      Todo.Draft(rank: "0", listID: 1)
//    ])
//    // not editing
//    let m1 = DashboardModel()
//    m1.listRowTapped(id: 1)
//    #expect(m1.editingListID == nil)
//    expectNoDifference(m1.navPath, [.listDetail(1)])
//    // editing
//    let m2 = DashboardModel(isEditing: true)
//    m2.listRowTapped(id: 1)
//    #expect(m2.editingListID == 1)
//    expectNoDifference(m2.navPath, [.listDetail(1)])
//  }
//  
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
//}
