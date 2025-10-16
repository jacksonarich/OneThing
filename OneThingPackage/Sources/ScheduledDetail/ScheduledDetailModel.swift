import Dependencies
import Foundation
import SQLiteData
import SwiftUI

import ModelActions
import Schema
import Utilities


@MainActor
@Observable
public final class ScheduledDetailModel {

  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions

  @ObservationIgnored
  @Dependency(\.continuousClock)
  private var clock

  @ObservationIgnored
  @FetchAll(
    TodoList
      .all
      .order(by: \.name)
  ) var movableLists

  @ObservationIgnored
  @FetchAll
  var todos: [Todo]
  
  private(set) var transitionTask: Task<Void, Never>? = nil

  private(set) var transitioningTodoIDs: Set<Todo.ID> = []

  private(set) var highlightedTodoIDs: Set<Todo.ID> = []

  private var todosQuery: SelectOf<Todo> {
    Todo
      .where { t in
        t.isScheduled
        .or(transitioningTodoIDs.contains(t.id))
      }
      .order { $0.deadline.asc(nulls: .last) }
  }
  
  public init() {
    self._todos = FetchAll(todosQuery)
  }
}


public extension ScheduledDetailModel {
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
      try modelActions.completeTodo(id)
    }
  }
  func _completeTodoPhase3(id: Todo.ID) async {
    do {
      try await clock.sleep(for: .seconds(2))
      transitioningTodoIDs.removeAll()
      try await $todos.load(todosQuery, animation: .default)
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
    }
  }
  func _putBackTodoPhase3(id: Todo.ID) async {
    do {
      try await clock.sleep(for: .seconds(2))
      transitioningTodoIDs.removeAll()
      try await $todos.load(todosQuery, animation: .default)
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
