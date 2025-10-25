import Dependencies
import Foundation
import SQLiteData
import SwiftUI

import ModelActions
import AppModels
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
  @FetchAll
  var todos: [Todo]

  private var todosQuery: SelectOf<Todo> {
    Todo
      .where { $0.isDeleted }
      .order { $0.deleteDate.desc(nulls: .last) }
  }
  
  public init() {
    self._todos = FetchAll(todosQuery, animation: .default)
  }
}


public extension DeletedDetailModel {
  
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
