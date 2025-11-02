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


@MainActor
@Suite(
  .dependency(\.continuousClock, ImmediateClock()),
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.uuid, .incrementing),
  .dependency(\.date.now, Date(timeIntervalSince1970: 0))
)
struct DashboardTests {
  
  @Test
  func testDashboardInit() async throws {
    let m = DashboardModel()
    #expect(m.isCreatingList == false)
    #expect(m.editingListID == nil)
    #expect(m.deletingListID == nil)
    #expect(m.editMode == .inactive)
  }
  
  @Test
  func testListRowTapped() async throws {
    // setup
    try ModelActions.testValue.seedDatabase([
      TodoList.Draft()
    ], [
      Todo.Draft(rank: "0", listID: 1)
    ])
    // not editing
    let m1 = DashboardModel()
    m1.listRowTapped(id: 1)
    #expect(m1.editingListID == nil)
    expectNoDifference(m1.navPath, [.listDetail(1)])
    // editing
    let m2 = DashboardModel(isEditing: true)
    m2.listRowTapped(id: 1)
    #expect(m2.editingListID == 1)
    expectNoDifference(m2.navPath, [.listDetail(1)])
  }
  
  @Test
  func testListCellTapped() async throws {
    // setup
    try ModelActions.testValue.seedDatabase([
      TodoList.Draft()
    ], [
      Todo.Draft(rank: "0", listID: 1)
    ])
    // tap "In Progress"
    let m = DashboardModel()
    m.listCellTapped(list: .inProgress)
    expectNoDifference(m.navPath, [.computedListDetail(.inProgress)])
  }
  
  @Test
  func testListVisibilityChanged() async throws {
    // setup
    try ModelActions.testValue.seedDatabase([
      TodoList.Draft()
    ], [
      Todo.Draft(rank: "0", listID: 1)
    ])
    let model = DashboardModel()
    // true -> false
    model.listVisibilityChanged(list: .inProgress, to: false)
    expectNoDifference(model.hiddenLists, [.inProgress])
    // false -> false
    model.listVisibilityChanged(list: .inProgress, to: false)
    expectNoDifference(model.hiddenLists, [.inProgress])
    // false -> true
    model.listVisibilityChanged(list: .inProgress, to: true)
    expectNoDifference(model.hiddenLists, [])
    // true -> true
    model.listVisibilityChanged(list: .inProgress, to: true)
    expectNoDifference(model.hiddenLists, [])
  }
}
