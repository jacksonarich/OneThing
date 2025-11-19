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
  
  var editingTodo: Todo?
  
  public init(
    editingTodo: Todo? = nil
  ) {
    self.editingTodo = editingTodo
  }
}


public extension InProgressDetailModel {
  
  func todoRowTapped(_ todoID: Todo.ID, shouldTransition: Bool) {
    modelTransitions.setTransition(todoID, to: shouldTransition ? TransitionAction.complete : nil)
  }
  
  func deleteTodo(_ todoID: Todo.ID) {
    withErrorReporting {
      try modelActions.deleteTodo(todoID)
    }
  }
  
  func editTodo(_ todo: Todo) {
    editingTodo = todo
  }
  
  func moveTodo(_ todoID: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(todoID, listID)
    }
  }
}
