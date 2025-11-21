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
  
  let listID: TodoList.ID
  var isCreatingTodo: Bool
  var editingTodoID: Todo.ID?
  private(set) var hapticID = 0
  private var modelTransitions = ModelTransitions()

  public init(
    listID: TodoList.ID,
    isCreatingTodo: Bool = false,
    editingTodoID: Todo.ID? = nil
  ) {
    self.listID = listID
    self.isCreatingTodo = isCreatingTodo
    self.editingTodoID = editingTodoID
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
  
  func editTodo(_ todoID: Todo.ID) {
    editingTodoID = todoID
  }
  
  func moveTodo(_ todoID: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(todoID, listID)
    }
  }
  
  func newTodoButtonTapped() {
    isCreatingTodo.toggle()
  }
  
  func rerankTodos(_ indexes: IndexSet, _ targetIndex: Int) {
    let todoIDs = indexes.map { todos[$0].id }
    let targetExists = todos.indices.contains(targetIndex)
    let targetID = targetExists ? todos[targetIndex].id : nil
    withErrorReporting {
      try modelActions.rerankTodos(todoIDs, targetID)
    }
  }
}
