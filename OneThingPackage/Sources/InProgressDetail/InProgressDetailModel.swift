import Dependencies
import Foundation
import SQLiteData
import StructuredQueriesCore
import SwiftUI

import ModelActions
import AppModels
import Utilities


@MainActor
@Observable
public final class InProgressDetailModel {

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
  var todoGroups: [TodoListWithTodos]
  
  private(set) var transitionTask: Task<Void, Never>? = nil

  private(set) var transitioningTodoIDs: Set<Todo.ID> = []

  private(set) var highlightedTodoIDs: Set<Todo.ID> = []
  
  private var todoGroupsQuery: some StructuredQueriesCore.Statement<TodoListWithTodos> {
    TodoList
      .group(by: \.id)
      .order(by: \.name)
      .join(Todo.all) { l, t in
        t.listID.eq(l.id)
        .and(
          t.isInProgress
          .or(transitioningTodoIDs.contains(t.id))
        )
      }
      .select { l, t in
        TodoListWithTodos.Columns(
          list: l,
          todos: t.jsonGroupArray()
        )
      }
  }
  
  public init() {
    self._todoGroups = FetchAll(todoGroupsQuery)
  }
}


public extension InProgressDetailModel {
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
      try await $todoGroups.load(todoGroupsQuery)
      try modelActions.completeTodo(id)
    }
  }
  func _completeTodoPhase3(id: Todo.ID) async {
    do {
      try await clock.sleep(for: .seconds(2))
      transitioningTodoIDs.removeAll()
      try await $todoGroups.load(todoGroupsQuery, animation: .default)
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
      try await $todoGroups.load(todoGroupsQuery)
    }
  }
  func _putBackTodoPhase3(id: Todo.ID) async {
    do {
      try await clock.sleep(for: .seconds(2))
      transitioningTodoIDs.removeAll()
      try await $todoGroups.load(todoGroupsQuery, animation: .default)
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
