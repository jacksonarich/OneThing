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
  func testCompleteTodo() async throws {
    let didComplete = LockIsolated(false)
    try await withDependencies {
      $0.modelActions.completeTodo = { _ in
        didComplete.withValue { $0 = true }
      }
    } operation: {
      try ModelActions.testValue.createList(.preset())
      try ModelActions.testValue.createTodo(.preset(order: "", listID: 1))
      let model = DashboardModel()
      // phase 1
      model._completeTodoPhase1(id: 1)
      expectNoDifference(model.transitioningTodoIDs, [1])
      expectNoDifference(model.highlightedTodoIDs, [1])
      // phase 2
      await model._completeTodoPhase2(id: 1)
      #expect(didComplete.value)
      // phase 3
      await model._completeTodoPhase3(id: 1)
      expectNoDifference(model.transitioningTodoIDs, [])
      expectNoDifference(model.highlightedTodoIDs, [])
    }
  }
  
  @Test
  func testDeleteTodo() async throws {
    let didDelete = LockIsolated(false)
    try withDependencies {
      $0.modelActions.deleteTodo = { _ in
        didDelete.withValue { $0 = true }
      }
    } operation: {
      try ModelActions.testValue.createList(.preset())
      try ModelActions.testValue.createTodo(.preset(order: "", listID: 1))
      let model = DashboardModel()
      // delete
      model.deleteTodo(id: 1)
      #expect(didDelete.value)
    }
  }
  
  @Test
  func testPutBackTodo() async throws {
    let didPutBack = LockIsolated(false)
    try await withDependencies {
      $0.modelActions.putBackTodo = { _ in
        didPutBack.withValue { $0 = true }
      }
    } operation: {
      try ModelActions.testValue.createList(.preset())
      try ModelActions.testValue.createTodo(.preset(order: "", listID: 1))
      try ModelActions.testValue.createTodo(.preset(order: "", listID: 1))
      let model = DashboardModel()
      // put back
      model._completeTodoPhase1(id: 1)
      await model._completeTodoPhase2(id: 1)
      model._completeTodoPhase1(id: 2)
      await model._completeTodoPhase2(id: 2)
      expectNoDifference(model.transitioningTodoIDs, [1,2])
      expectNoDifference(model.highlightedTodoIDs, [1,2])
      // phase 1
      model._putBackTodoPhase1(id: 1)
      expectNoDifference(model.transitioningTodoIDs, [2])
      expectNoDifference(model.highlightedTodoIDs, [2])
      // phase 2
      await model._putBackTodoPhase2(id: 1)
      #expect(didPutBack.value)
      // phase 3
      await model._putBackTodoPhase3(id: 1)
      expectNoDifference(model.transitioningTodoIDs, [])
      expectNoDifference(model.highlightedTodoIDs, [])
    }
  }
  
  @Test
  func testMoveTodo() async throws {
    let didMove = LockIsolated(false)
    try withDependencies {
      $0.modelActions.moveTodo = { _,_ in
        didMove.withValue { $0 = true }
      }
    } operation: {
      try ModelActions.testValue.createList(.preset())
      try ModelActions.testValue.createList(.preset())
      try ModelActions.testValue.createTodo(.preset(order: "", listID: 1))
      let model = DashboardModel()
      // move
      model.moveTodo(id: 1, to: 2)
      #expect(didMove.value)
    }
  }
  
  @Test
  func testListRowTapped() async throws {
    try ModelActions.testValue.createList(.preset())
    try ModelActions.testValue.createTodo(.preset(order: "", listID: 1))
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
    try ModelActions.testValue.createList(.preset())
    try ModelActions.testValue.createTodo(.preset(order: "", listID: 1))
    // tap "In Progress"
    let model = DashboardModel()
    model.listCellTapped(list: .inProgress)
    expectNoDifference(model.navPath, [.computedListDetail(.inProgress)])
  }
  
  @Test
  func testListVisibilityChanged() async throws {
    try ModelActions.testValue.createList(.preset())
    try ModelActions.testValue.createTodo(.preset(order: "", listID: 1))
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
