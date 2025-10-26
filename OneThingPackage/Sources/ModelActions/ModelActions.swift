// Interface used by view models to write to the database.


import SQLiteData
import SwiftUI

import AppModels


public struct ModelActions: Sendable {
  public var createTodo:       @Sendable (Todo.Draft)               throws -> Void
  public var completeTodo:     @Sendable (Todo.ID)                  throws -> Void
  public var unrescheduleTodo: @Sendable (Todo.ID, Date)            throws -> Void
  public var deleteTodo:       @Sendable (Todo.ID)                  throws -> Void
  public var putBackTodo:      @Sendable (Todo.ID)                  throws -> Void
  public var eraseTodo:        @Sendable (Todo.ID)                  throws -> Void
  public var moveTodo:         @Sendable (Todo.ID, TodoList.ID)     throws -> Void
  public var createList:       @Sendable (TodoList.Draft)           throws -> Void
  public var updateList:       @Sendable (TodoList.ID, String, Int) throws -> Void
  public var deleteList:       @Sendable (TodoList.ID)              throws -> Void
}


public extension DependencyValues {
  var modelActions: ModelActions {
    get { self[ModelActions.self] }
    set { self[ModelActions.self] = newValue }
  }
}


extension ModelActions: DependencyKey {
  public static let liveValue = {
    @Dependency(\.defaultDatabase) var connection
    @Dependency(\.date.now) var now
    return Self(
      createTodo: { todo in
        try connection.write { db in
          try Todo
            .insert { todo }
            .execute(db)
        }
      },
      completeTodo: { todoID in
        try connection.write { db in
          guard let todo = try Todo
            .find(todoID)
            .fetchOne(db) else { return }
          if let deadline = todo.deadline, let frequencyUnitIndex = todo.frequencyUnitIndex, let frequencyCount = todo.frequencyCount {
            let frequencyUnit = Calendar.Component.all[frequencyUnitIndex]
            let newDeadline = deadline.nextFutureDate(
              unit: frequencyUnit,
              count: frequencyCount
            )
            try Todo
              .find(todoID)
              .update { $0.deadline = newDeadline }
              .execute(db)
          } else {
            try Todo
              .find(todoID)
              .update { $0.completeDate = now }
              .execute(db)
          }
        }
      },
      unrescheduleTodo: { todoID, oldDeadline in
        try connection.write { db in
          try Todo
            .find(todoID)
            .update { $0.deadline = oldDeadline }
            .execute(db)
        }
      },
      deleteTodo: { todoID in
        try connection.write { db in
          try Todo
            .find(todoID)
            .update { $0.deleteDate = now }
            .execute(db)
        }
      },
      putBackTodo: { todoID in
        try connection.write { db in
          try Todo
            .find(todoID)
            .update {
              $0.completeDate = nil
              $0.deleteDate = nil
            }
            .execute(db)
        }
      },
      eraseTodo: { todoID in
        try connection.write { db in
          try Todo
            .find(todoID)
            .delete()
            .execute(db)
        }
      },
      moveTodo: { todoID, listID in
        try connection.write { db in
          try Todo
            .find(todoID)
            .update { $0.listID = listID }
            .execute(db)
        }
      },
      createList: { list in
        try connection.write { db in
          try TodoList
            .insert { list }
            .execute(db)
        }
      },
      updateList: { listID, listName, listColorIndex in
        try connection.write { db in
          try TodoList
            .find(listID)
            .update {
              $0.name = listName
              $0.colorIndex = listColorIndex
            }
            .execute(db)
        }
      },
      deleteList: { listID in
        try connection.write { db in
          try Todo
            .where { $0.listID.eq(listID) }
            .delete()
            .execute(db)
          try TodoList
            .find(listID)
            .delete()
            .execute(db)
        }
      }
    )
  }()
  
  public static let testValue = liveValue
}


extension Date {
  func nextFutureDate(
    unit:  Calendar.Component,
    count: Int
  ) -> Date {
    @Dependency(\.date) var date
    if count <= 0 { return self }
    let calendar = Calendar.current
    guard let difference = calendar
      .dateComponents([unit], from: self, to: date.now)
      .value(for: unit)
    else { return self }
    let steps = Swift.max(1, (difference / count) + 1)
    return calendar.date(byAdding: unit, value: steps * count, to: self) ?? self
  }
}
