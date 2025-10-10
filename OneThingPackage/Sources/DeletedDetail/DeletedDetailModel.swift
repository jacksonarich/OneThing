import Dependencies
import Foundation
import SQLiteData
import SwiftUI

import ModelActions
import Schema
import Utilities


@MainActor
@Observable
public final class DeletedDetailModel {

  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions

  @ObservationIgnored
  @Dependency(\.continuousClock)
  private var clock

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
  @FetchAll
  var todos: [Todo]

  @ObservationIgnored
  @FetchOne
  var stats: Stats?

  public init(
    searchText: String = ""
  ) {
    self.searchText = searchText
    self._todos = FetchAll(todosQuery)
    self._stats = FetchOne(statsQuery)
  }

  private var todosQuery: SelectOf<Todo> {
    Todo
      .where { t in
        (t.isDeleted
        .and(t.search(searchText)))
        .or(transitioningTodoIDs.contains(t.id))
      }
      .order(by: \.title)
  }

  private var statsQuery: Select<Stats, Todo, ()> {
    Todo.select { t in
      Stats.Columns(
        isEmpty: t.count(filter:
          t.isDeleted
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


public extension DeletedDetailModel {
  
  func deleteTodo(id: Todo.ID) {
    _deleteTodoPhase1(id: id)
    Task { await _deleteTodoPhase2(id: id) }
    transitionTask = Task { await _deleteTodoPhase3(id: id) }
  }
  func _deleteTodoPhase1(id: Todo.ID) {
    transitionTask?.cancel()
    transitioningTodoIDs.remove(id)
    highlightedTodoIDs.remove(id)
  }
  func _deleteTodoPhase2(id: Todo.ID) async {
    await withErrorReporting {
      try modelActions.deleteTodo(id)
      try await $todos.load(todosQuery)
      try await $stats.load(statsQuery)
    }
  }
  func _deleteTodoPhase3(id: Todo.ID) async {
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
  
  func putBackTodo(id: Todo.ID) {
    _putBackTodoPhase1(id: id)
    Task { await _putBackTodoPhase2(id: id) }
    transitionTask = Task { await _putBackTodoPhase3(id: id) }
  }
  func _putBackTodoPhase1(id: Todo.ID) {
    transitionTask?.cancel()
    transitioningTodoIDs.insert(id)
    highlightedTodoIDs.insert(id)
  }
  func _putBackTodoPhase2(id: Todo.ID) async {
    await withErrorReporting {
      try await $todos.load(todosQuery)
      try await $stats.load(statsQuery)
      try modelActions.putBackTodo(id)
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
  
  func eraseTodo(id: Todo.ID) {
    withErrorReporting {
      try modelActions.eraseTodo(id)
    }
  }
  
  func moveTodo(id: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(id, listID)
    }
  }
}
