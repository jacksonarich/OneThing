import AppModels
import Dependencies
import Foundation
import ModelActions
import SQLiteData
import SwiftUI
import Utilities


@MainActor
@Observable
public final class DeletedDetailModel {

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
      .where { $0.isDeleted }
      .order { $0.deleteDate.desc() },
    animation: .default
  )
  var todos: [Todo]
  
  public init() {}
}


public extension DeletedDetailModel {
  
  func putBackTodo(_ todoID: Todo.ID) {
    withErrorReporting {
      try modelActions.putBackTodo(todoID)
    }
  }
  
  func eraseTodo(_ todoID: Todo.ID) {
    withErrorReporting {
      try modelActions.eraseTodo(todoID)
    }
  }
  
  func moveTodo(_ todoID: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(todoID, listID)
    }
  }
}
