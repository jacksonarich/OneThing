import Dependencies
import Foundation
import SQLiteData
import StructuredQueriesCore
import SwiftUI

import AppModels
import ModelActions
import ModelTransitions
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

  @ObservationIgnored
  private var modelTransitions = ModelTransitions()
  
  public init() {}
}


public extension InProgressDetailModel {
  func toggleComplete(_ todoID: Todo.ID, complete shouldComplete: Bool) {
    modelTransitions.toggleComplete(todoID, complete: shouldComplete)
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
