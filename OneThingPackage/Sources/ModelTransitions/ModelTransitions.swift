// Interface used by view models to write to the database.


import SQLiteData
import StructuredQueriesCore
import SwiftUI

import AppModels
import ModelActions


@MainActor
public struct ModelTransitions {
  
  @Dependency(\.modelActions)
  private var modelActions
  
  @Dependency(\.continuousClock)
  private var clock
  
  private var timerTask: Task<Void, Never>? = nil
  
  public mutating func toggleComplete(_ todoId: Todo.ID, complete shouldComplete: Bool) {
    timerTask?.cancel()
    withErrorReporting {
      try modelActions.transitionTodo(todoId, shouldComplete)
      timerTask = Task { [clock, modelActions] in
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
  
  public init() {}
}
