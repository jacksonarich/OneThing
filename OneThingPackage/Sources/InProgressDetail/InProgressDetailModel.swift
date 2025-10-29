import Dependencies
import Foundation
import IdentifiedCollections
import SQLiteData
import StructuredQueriesCore
import SwiftUI

import AppModels
import ModelActions
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

  private var timerTask: Task<Void, Never>?
  
  public init() {

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
  
  func moveTodo(id: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(id, listID)
    }
  }
}
