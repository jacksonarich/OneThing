import Dependencies
import Foundation
import SQLiteData
import SwiftUI

import ModelActions
import AppModels
import Utilities


@MainActor
@Observable
public final class CompletedDetailModel {

  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions

  @ObservationIgnored
  @FetchAll(
    TodoList
      .all
      .order(by: \.name)
  ) var movableLists

  @ObservationIgnored
  @FetchAll(
    Todo
      .where { $0.isCompleted }
      .order { $0.completeDate.desc() },
    animation: .default
  )
  var todos: [Todo]
  
  public init() {}
}


public extension CompletedDetailModel {
  
  func putBackTodo(id: Todo.ID) {
    withErrorReporting {
      try modelActions.putBackTodo(id)
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
