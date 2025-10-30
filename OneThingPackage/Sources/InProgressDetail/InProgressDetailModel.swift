import Dependencies
import Foundation
import IdentifiedCollections
import SQLiteData
import StructuredQueriesCore
import SwiftUI

import AppModels
import ModelActions
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
  @FetchAll(
    TodoList
      .group(by: \.id)
      .order(by: \.name)
      .join(Todo.all) { list, todo in
        todo.listID.eq(list.id).and(todo.isInProgress)
      }
      .select { list, todo in
        TodoListWithTodos.Columns(
          list: list,
          todos: todo.jsonGroupArray()
        )
      },
    animation: .default
  )
  var todoGroups: [TodoListWithTodos]

  private var timerTask: Task<Void, Never>?
  
  public init() {}
}


public extension InProgressDetailModel {
  func toggleComplete(_ todo: Todo) {
    timerTask?.cancel()
    withErrorReporting {
      if todo.isTransitioning {
        try modelActions.transitionTodo(todo.id, false)
      } else {
        try modelActions.transitionTodo(todo.id, true)
        timerTask = Task { [clock] in
          do {
            try await clock.sleep(for: .seconds(2))
            try modelActions.finalizeTransitions()
          } catch {
            if error is CancellationError { return }
            reportIssue(error)
          }
        }
      }
    }
  }
  
  func deleteTodo(_ todo: Todo) {
    withErrorReporting {
      try modelActions.deleteTodo(todo.id)
    }
  }
  
  func moveTodo(id: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(id, listID)
    }
  }
}
