import AppModels
import Dependencies
import Foundation
import ModelActions
import ModelTransitions
import SQLiteData
import StructuredQueriesCore
import SwiftUI
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
  
  @ObservationIgnored
  private var modelTransitions = ModelTransitions()
  
  private var timerTask: Task<Void, Never>?
  
  public init() {}
}


public extension ScheduledDetailModel {
  
  func todoRowTapped(_ todoID: Todo.ID, isTransitioning: Bool) {
    modelTransitions.setTransition(todoID, to: isTransitioning == false)
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
