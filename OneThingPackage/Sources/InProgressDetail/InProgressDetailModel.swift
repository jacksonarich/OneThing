import Dependencies
import Foundation
import IdentifiedCollections
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
      .join(
        Todo
          .where { $0.deleteDate.is(nil) }
          .leftJoin(Transition.all) { $0.id.eq($1.todoID) }
          .where {
            $0.completeDate.is(nil) || $1.isNot(nil)
          }
      ) {
        $0.id.eq($1.listID)
      }
      .select {
        TodoListWithTodos.Columns(
          list: $0,
          todos: $1.jsonGroupArray()
        )
      }
  )
  var todoGroups: [TodoListWithTodos]
  
//  private var removing = IdentifiedArrayOf<Todo>()
//  private var inserting = Set<Todo.ID>()
  private var timerTask: Task<Void, Never>?
//  
//  var displayGroups: [TodoListWithTodos] {
//    var groups = todoGroups
//    for todo in removing {
//      
//    }
//  }
  
  // PROBLEM: modelTransitions and todoGroupsQuery fundamentally depend on each other
  
//  private var modelTransitions: ModelTransitions
    
//  private func rawTodoGroupsQuery(
//    transitions: Transitions = .init()
//  ) -> some StructuredQueriesCore.Statement<TodoListWithTodos> {
//    TodoList
//      .group(by: \.id)
//      .order(by: \.name)
//      .join(Todo.all) { l, t in
//        t.listID.eq(l.id)
//          .and(transitions.isVisible(t.id, wrapping: t.isInProgress))
//      }
//      .select { l, t in
//        TodoListWithTodos.Columns(
//          list: l,
//          todos: t.jsonGroupArray()
//        )
//      }
//  }
  
  public init() {
//    self._rawTodoGroups = FetchAll(rawTodoGroupsQuery, animation: .default)
//    self.modelTransitions = ModelTransitions {
//      try! await self.$rawTodoGroups.load(self.rawTodoGroupsQuery(), animation: .default)
//    }
  }
}


public extension InProgressDetailModel {
  func toggleComplete(_ todo: Todo) {
    timerTask?.cancel()
    withErrorReporting {
      let isCompleting = todo.completeDate == nil
      if isCompleting {
        let originalDeadline = todo.deadline
        try modelActions.completeTodo(todo.id)
        try modelActions.enterPhase(todo.id, .phase1, originalDeadline)
        timerTask = Task { [clock] in
          do {
            try await clock.sleep(for: .seconds(2))
            finishCompleting()
          } catch {
            if error is CancellationError { return }
            reportIssue(error)
          }
        }
      } else {
        if let originalDeadline, todo.frequencyCount != nil {
          try modelActions.unrescheduleTodo(todo.id, originalDeadline)
        } else {
          try modelActions.putBackTodo(todo.id)
        }
      }
    }
  }
  
  private func finishCompleting() {
    let removedIds = removing.elements.map(\.id)
    inserting.formUnion(removedIds)
    removing.removeAll()
    Task {
      try await clock.sleep(for: .seconds(2))
      inserting.subtract(removedIds)
    }
  }
  
  func deleteTodo(_ todo: Todo) {
    withErrorReporting {
      try modelActions.deleteTodo(todo.id)
    }
  }
  
//  func putBackTodo(_ todo: Todo) {
//    modelTransitions?.putBackTodo(todo, undo: true)
//  }
  
  func moveTodo(id: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(id, listID)
    }
  }
}
