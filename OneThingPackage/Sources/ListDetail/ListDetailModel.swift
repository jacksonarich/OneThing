import AppModels
import Dependencies
import Foundation
import ModelActions
import ModelTransitions
import SQLiteData
import SwiftUI
import Utilities


@MainActor
@Observable
public final class ListDetailModel {

  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions

  private(set) var listID: TodoList.ID
  private var modelTransitions = ModelTransitions()
  var isCreatingTodo = false
  private var hapticID = 0

  @ObservationIgnored
  @FetchAll(
    TodoList
      .all
      .order(by: \.name)
  ) var movableLists

  @ObservationIgnored
  @FetchOne
  var list: TodoList?

  @ObservationIgnored
  @FetchAll
  var todos: [Todo]

  public init(
    listID: TodoList.ID,
  ) {
    self.listID = listID
    self._list = FetchOne(TodoList.find(listID))
    self._todos = FetchAll(
      Todo
        .where { t in
          t.listID.eq(listID)
          .and(t.isInProgress)
        }
        .order(by: \.rank),
      animation: .default
    )
  }
}


public extension ListDetailModel {
  
  func todoRowTapped(_ todoID: Todo.ID, shouldTransition: Bool) {
    modelTransitions.setTransition(todoID, to: shouldTransition ? TransitionAction.complete : nil)
    hapticID += 1
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
  
  func newTodoButtonTapped() {
    isCreatingTodo.toggle()
  }
}
