import Dependencies
import Foundation
import SQLiteData
import StructuredQueriesCore
import SwiftUI

import ModelActions
<<<<<<< Updated upstream
import AppModels
=======
import ModelTransitions
import Schema
>>>>>>> Stashed changes
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
  @FetchAll
  var rawTodoGroups: [TodoListWithTodos]
  
  var todoGroups: [TodoListWithTodos] {
    // PROBLEM: how to combine rawTodoGroups and modelTransitions?
  }
  
  // PROBLEM: modelTransitions and todoGroupsQuery fundamentally depend on each other
  
  private var modelTransitions: ModelTransitions?
  
  private var rawTodoGroupsQuery: some StructuredQueriesCore.Statement<TodoListWithTodos> {
    TodoList
      .group(by: \.id)
      .order(by: \.name)
      .join(Todo.all) { l, t in
        t.listID.eq(l.id)
        .and(modelTransitions?.isVisible(t, wrapping: t.isInProgress) ?? true)
      }
      .select { l, t in
        TodoListWithTodos.Columns(
          list: l,
          todos: t.jsonGroupArray()
        )
      }
  }
  
  public init() {
    self._todoGroups = FetchAll(todoGroupsQuery, animation: .default)
    self.modelTransitions = ModelTransitions {
      try! await self.$todoGroups.load(self.todoGroupsQuery, animation: .default)
    }
  }
}


public extension InProgressDetailModel {
  func completeTodo(_ todo: Todo) {
    modelTransitions?.completeTodo(todo)
  }
  
  func deleteTodo(_ todo: Todo) {
    withErrorReporting {
      try modelActions.deleteTodo(todo.id)
    }
  }
  
  func putBackTodo(_ todo: Todo) {
    modelTransitions?.putBackTodo(todo, undo: true)
  }
  
  func moveTodo(id: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(id, listID)
    }
  }
}
