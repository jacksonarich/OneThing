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
    let m1 = DashboardModel()
    #expect(m1.isCreatingList == false)
    #expect(m1.editingListID == nil)
    #expect(m1.deletingListID == nil)
    #expect(m1.editMode == .inactive)
    #expect(m1.searchText == "")
  }
  
  @Test
  func testListRowTapped() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(.init(order: "", listID: 1))
    // not editing
    let model1 = DashboardModel()
    model1.listRowTapped(id: 1)
    #expect(model1.editingListID == nil)
    expectNoDifference(model1.navPath, [.listDetail(1)])
    // editing
    let model2 = DashboardModel(isEditing: true)
    model2.listRowTapped(id: 1)
    #expect(model2.editingListID == 1)
    expectNoDifference(model2.navPath, [.listDetail(1)])
  }
  
  @Test
  func testListCellTapped() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(.init(order: "", listID: 1))
    // tap "In Progress"
    let model = DashboardModel()
    model.listCellTapped(list: .inProgress)
    expectNoDifference(model.navPath, [.computedListDetail(.inProgress)])
  }
  
  @Test
  func testListVisibilityChanged() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(.init(order: "", listID: 1))
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
