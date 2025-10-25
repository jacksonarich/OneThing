import Dependencies
import Foundation
import SQLiteData
import SwiftUI

import ModelActions
import AppModels
import Utilities


@MainActor
@Observable
public final class ListDetailModel {

  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions

  @ObservationIgnored
  @Dependency(\.continuousClock)
  private var clock

  private(set) var listID: TodoList.ID

  private(set) var transitionTask: Task<Void, Never>? = nil

  private(set) var transitioningTodoIDs: Set<Todo.ID> = []

  private(set) var highlightedTodoIDs: Set<Todo.ID> = []

  var searchText: String {
    didSet {
      let t = $todos
      let q = todosQuery
      Task { try await t.load(q) }
    }
  }

  @ObservationIgnored
  @FetchAll(
    TodoList
      .all
      .order(by: \.name)
  ) var movableLists

  @ObservationIgnored
  @FetchOne
  var list: TodoList?

  @ObservationIgnored
  @FetchAll
  var todos: [Todo]

  @ObservationIgnored
  @FetchOne
  var stats: Stats?

  public init(
    listID: TodoList.ID,
    searchText: String = ""
  ) {
    self.listID = listID
    self.searchText = searchText
    self._list = FetchOne(listQuery)
    self._todos = FetchAll(todosQuery)
    self._stats = FetchOne(statsQuery)
  }

  private var listQuery: Where<TodoList> {
    TodoList.find(listID)
  }

  private var todosQuery: SelectOf<Todo> {
    Todo
      .where { t in
        (t.listID.eq(listID)
        .and(t.isInProgress)
        .and(t.search(searchText)))
        .or(transitioningTodoIDs.contains(t.id))
      }
      .order(by: \.title)
  }

  private var statsQuery: Select<Stats, Todo, ()> {
    Todo.select { t in
      Stats.Columns(
        isEmpty: t.count(filter:
          (t.listID.eq(listID)
          .and(t.isInProgress))
          .or(transitioningTodoIDs.contains(t.id))
        ).eq(0)
      )
    }
  }

  @Selection
  struct Stats {
    var isEmpty: Bool
  }
}


public extension ListDetailModel {
  func completeTodo(id: Todo.ID) {
    _completeTodoPhase1(id: id)
    Task { await _completeTodoPhase2(id: id) }
    transitionTask = Task { await _completeTodoPhase3(id: id) }
  }
  func _completeTodoPhase1(id: Todo.ID) {
    transitionTask?.cancel()
    transitioningTodoIDs.insert(id)
    highlightedTodoIDs.insert(id)
  }
  func _completeTodoPhase2(id: Todo.ID) async {
    await withErrorReporting {
      try await $todos.load(todosQuery)
      try await $stats.load(statsQuery)
      try modelActions.completeTodo(id)
    }
  }
  func _completeTodoPhase3(id: Todo.ID) async {
    do {
      try await clock.sleep(for: .seconds(2))
      transitioningTodoIDs.removeAll()
      try await $todos.load(todosQuery, animation: .default)
      try await $stats.load(statsQuery, animation: .default)
      highlightedTodoIDs.removeAll()
    } catch is CancellationError {
    } catch {
      withErrorReporting { throw error }
    }
  }
  
  func deleteTodo(id: Todo.ID) {
    withErrorReporting {
      try modelActions.deleteTodo(id)
    }
  }
  
  func putBackTodo(id: Todo.ID) {
    _putBackTodoPhase1(id: id)
    Task { await _putBackTodoPhase2(id: id) }
    transitionTask = Task { await _putBackTodoPhase3(id: id) }
  }
  func _putBackTodoPhase1(id: Todo.ID) {
    transitionTask?.cancel()
    transitioningTodoIDs.remove(id)
    highlightedTodoIDs.remove(id)
  }
  func _putBackTodoPhase2(id: Todo.ID) async {
    await withErrorReporting {
      try modelActions.putBackTodo(id)
      try await $todos.load(todosQuery)
      try await $stats.load(statsQuery)
    }
  }
  func _putBackTodoPhase3(id: Todo.ID) async {
    do {
      try await clock.sleep(for: .seconds(2))
      transitioningTodoIDs.removeAll()
      try await $todos.load(todosQuery, animation: .default)
      try await $stats.load(statsQuery, animation: .default)
      highlightedTodoIDs.removeAll()
    } catch is CancellationError {
    } catch {
      withErrorReporting { throw error }
    }
  }
  
  func moveTodo(id: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(id, listID)
    }
  }
}
