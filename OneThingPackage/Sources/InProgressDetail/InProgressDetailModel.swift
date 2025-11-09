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
public final class InProgressDetailModel {

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
    TodoList
      .group(by: \.id)
      .order(by: \.name)
      .join(Todo.all) { l, t in
        t.listID.eq(l.id)
        .and(t.isInProgress)
      }
      .select { l, t in
        TodoListWithTodos.Columns(
          list: l,
          todos: t.jsonGroupArray()
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
