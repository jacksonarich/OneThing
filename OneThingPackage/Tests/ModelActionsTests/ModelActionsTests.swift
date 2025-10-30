import CustomDump
import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import StructuredQueries
import Testing

import AppDatabase
import ModelActions
import AppModels
import Utilities


let now = Date(timeIntervalSince1970: 0)


@Suite(
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.uuid, .incrementing),
  .dependency(\.date.now, now)
)
struct ModelActionsTests {
  
  @Test
  func testCreateList() async throws {
    try ModelActions.testValue.createList(.init())
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([.init(id: 1)], allLists)
    expectNoDifference([], allTodos)
  }
  
  @Test
  func testUpdateList() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.updateList(1, "Grocery", 5)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([.init(id: 1, name: "Grocery", colorIndex: 5)], allLists)
    expectNoDifference([], allTodos)
  }
  
  @Test
  func testDeleteList() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.deleteList(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([], allLists)
    expectNoDifference([], allTodos)
  }
  
  @Test
  func testCreateTodo() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(.init(order: "", listID: 1))
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([.init(id: 1)], allLists)
    expectNoDifference([.init(id: 1, order: "", listID: 1)], allTodos)
  }
  
  @Test
  func testCompleteTodo() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(.init(order: "", listID: 1))
    try ModelActions.testValue.completeTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([.init(id: 1)], allLists)
    expectNoDifference([.init(id: 1, completeDate: now, order: "", listID: 1)], allTodos)
  }
  
  @Test
  func testDeleteTodo() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(.init(order: "", listID: 1))
    try ModelActions.testValue.deleteTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([.init(id: 1)], allLists)
    expectNoDifference([.init(id: 1, deleteDate: now, order: "", listID: 1)], allTodos)
  }
  
  @Test
  func testPutBackTodo() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(.init(completeDate: now, deleteDate: now, order: "", listID: 1))
    try ModelActions.testValue.putBackTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([.init(id: 1)], allLists)
    expectNoDifference([.init(id: 1, order: "", listID: 1)], allTodos)
  }
  
  @Test
  func testEraseTodo() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(.init(order: "", listID: 1))
    try ModelActions.testValue.eraseTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([.init(id: 1)], allLists)
    expectNoDifference([], allTodos)
  }
  
  @Test
  func testMoveTodo() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(.init(order: "", listID: 1))
    try ModelActions.testValue.moveTodo(1, 2)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([.init(id: 1), .init(id: 2)], allLists)
    expectNoDifference([.init(id: 1, order: "", listID: 2)], allTodos)
  }
  
  @Test
  func testRescheduleTodo() async throws {
    try ModelActions.testValue.createList(.init())
    try ModelActions.testValue.createTodo(
      .init(deadline: now, frequencyUnitIndex: 0, frequencyCount: 2, order: "", listID: 1)
    )
    try ModelActions.testValue.completeTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference([.init(id: 1)], allLists)
    expectNoDifference([
      .init(id: 1, deadline: Calendar.current.date(byAdding: .day, value: 2, to: now), frequencyUnitIndex: 0, frequencyCount: 2, order: "", listID: 1)
    ], allTodos)
  }
}
