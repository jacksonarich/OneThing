import Dependencies
import Foundation
import SQLiteData
import StructuredQueriesCore
import SwiftUI

import AppModels
import ModelActions
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
  @FetchAll(
    Todo
      .where { $0.isScheduled }
      .order(by: \.deadline),
    animation: .default
  )
  var todos
  
  private var timerTask: Task<Void, Never>?
  
  public init() {}
}


public extension ScheduledDetailModel {
  func toggleComplete(_ todoId: Todo.ID, complete shouldComplete: Bool) {
    timerTask?.cancel()
    withErrorReporting {
      try modelActions.transitionTodo(todoId, shouldComplete)
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
  
  func deleteTodo(_ todoID: Todo.ID) {
    withErrorReporting {
      try modelActions.deleteTodo(todoID)
    }
  }
  
  func moveTodo(_ todoID: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(todoID, listID)
    }
  }
}
