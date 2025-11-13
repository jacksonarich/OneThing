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


@MainActor
struct DashboardTests {
  
  @Test(arguments: [false, true])
  func testListRowTapped(isEditing: Bool) async throws {
    await prepareTest {
      TodoListData()
    } test: {
      let model = DashboardModel(isEditing: isEditing)
      await runAction {
        model.listRowTapped(id: 1)
        #expect(model.editingListID == (isEditing ? 1 : nil))
        expectNoDifference(model.navPath, isEditing ? [] : [.listDetail(1)])
      } assert: { _ in
        // No changes
      }
    }
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
