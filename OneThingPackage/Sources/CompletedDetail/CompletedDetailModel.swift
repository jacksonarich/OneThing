import AppModels
import Dependencies
import Foundation
import ModelActions
import SQLiteData
import SwiftUI
import Utilities


@MainActor
@Observable
public final class CompletedDetailModel {

  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions

  @ObservationIgnored
  @FetchAll(
    Todo
      .where { $0.isCompleted }
      .where { $0.deleteDate.is(nil) }
      .order { $0.completeDate.desc() },
    animation: .default
  )
  var todos: [Todo]
  
  public init() {}
}


public extension CompletedDetailModel {
  
  func putBackTodo(_ todoID: Todo.ID) {
    withErrorReporting {
      try modelActions.putBackTodo(todoID)
    }
  }
  
  func deleteTodo(_ todoID: Todo.ID) {
    withErrorReporting {
      try modelActions.deleteTodo(todoID)
    }
  }
}
