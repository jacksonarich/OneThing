import AppModels
import ModelActions
import SQLiteData
import StructuredQueriesCore
import SwiftUI


@MainActor
public final class ModelTransitions {
  
  @Dependency(\.modelActions)
  private var modelActions
  
  @Dependency(\.continuousClock)
  private var clock
  
  private var timerTask: Task<Void, Never>? = nil
  
  public func setTransition(_ todoId: Todo.ID, to transition: TransitionAction?) {
    timerTask?.cancel()
    withErrorReporting {
      try modelActions.transitionTodo(todoId, transition)
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
