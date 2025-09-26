import AppDatabase
import CustomDump
import Dependencies
import DependenciesTestSupport
import Foundation
import GRDB
import Presets
import Schema
import SQLiteData
import StructuredQueries
import Testing

@testable import ModelActions


@Suite(
  .dependency(\.continuousClock, ImmediateClock()),
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.uuid, .incrementing),
  .dependency(\.date.now, Date(timeIntervalSince1970: 0))
)
struct ModelActionsTests {
  
  @Test
  func createList() async throws {
    try ModelActions.liveValue.createList(.preset())
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [.preset(id: 1)])
    expectNoDifference(allTodos, [])
  }
  
  @Test
  func updateList() async throws {
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.updateList(1, "Grocery", 5)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [.preset(id: 1, name: "Grocery", colorIndex: 5)])
    expectNoDifference(allTodos, [])
  }
  
  @Test
  func deleteList() async throws {
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.deleteList(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [])
    expectNoDifference(allTodos, [])
  }
  
  @Test
  func createTodo() async throws {
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.createTodo(.preset(id: 1, order: "", listID: 1))
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [.preset(id: 1)])
    expectNoDifference(allTodos, [.preset(id: 1, order: "", listID: 1)])
  }
  
  @Test
  func completeTodo() async throws {
    @Dependency(\.date) var date
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.createTodo(.preset(id: 1, order: "", listID: 1))
    try ModelActions.liveValue.completeTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [.preset(id: 1)])
    expectNoDifference(allTodos, [.preset(id: 1, completeDate: date.now, order: "", listID: 1)])
  }
  
  @Test
  func deleteTodo() async throws {
    @Dependency(\.date) var date
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.createTodo(.preset(id: 1, order: "", listID: 1))
    try ModelActions.liveValue.deleteTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [.preset(id: 1)])
    expectNoDifference(allTodos, [.preset(id: 1, deleteDate: date.now, order: "", listID: 1)])
  }
  
  @Test
  func putBackTodo() async throws {
    @Dependency(\.date) var date
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.createTodo(.preset(id: 1, completeDate: date.now, deleteDate: date.now, order: "", listID: 1))
    try ModelActions.liveValue.putBackTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [.preset(id: 1)])
    expectNoDifference(allTodos, [.preset(id: 1, order: "", listID: 1)])
  }
  
  @Test
  func eraseTodo() async throws {
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.createTodo(.preset(id: 1, order: "", listID: 1))
    try ModelActions.liveValue.eraseTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [.preset(id: 1)])
    expectNoDifference(allTodos, [])
  }
  
  @Test
  func moveTodo() async throws {
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.createTodo(.preset(id: 1, order: "", listID: 1))
    try ModelActions.liveValue.moveTodo(1, 2)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [.preset(id: 1), .preset(id: 2)])
    expectNoDifference(allTodos, [.preset(id: 1, order: "", listID: 2)])
  }
  
  @Test
  func rescheduleTodo() async throws {
    @Dependency(\.date) var date
    try ModelActions.liveValue.createList(.preset())
    try ModelActions.liveValue.createTodo(
      .preset(id: 1, deadline: date.now, frequencyUnitIndex: 0, frequencyCount: 2, order: "", listID: 1)
    )
    try ModelActions.liveValue.rescheduleTodo(1)
    @FetchAll(TodoList.Draft.all) var allLists
    @FetchAll(Todo.Draft.all) var allTodos
    expectNoDifference(allLists, [.preset(id: 1)])
    expectNoDifference(allTodos, [
      .preset(id: 1, deadline: Calendar.current.date(byAdding: .day, value: 2, to: date.now), frequencyUnitIndex: 0, frequencyCount: 2, order: "", listID: 1)
    ])
  }
}
