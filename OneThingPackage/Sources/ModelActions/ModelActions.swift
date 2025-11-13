import AppModels
import RankGeneration
import SQLiteData
import SwiftUI
import Utilities


public struct ModelActions: Sendable {
  public var createTodo: @Sendable (Todo.Draft) throws -> Void
  public var completeTodo: @Sendable (Todo.ID) throws -> Void
  public var deleteTodo: @Sendable (Todo.ID) throws -> Void
  public var putBackTodo: @Sendable (Todo.ID) throws -> Void
  public var eraseTodo: @Sendable (Todo.ID) throws -> Void
  public var moveTodo: @Sendable (Todo.ID, TodoList.ID) throws -> Void
  public var createList: @Sendable (TodoList.Draft) throws -> Void
  public var updateList: @Sendable (TodoList.ID, String, ListColor) throws -> Void
  public var deleteList: @Sendable (TodoList.ID) throws -> Void
  public var transitionTodo: @Sendable (Todo.ID, TransitionAction?) throws -> Void
  public var finalizeTransitions: @Sendable () throws -> Void
}


public extension DependencyValues {
  var modelActions: ModelActions {
    get { self[ModelActions.self] }
    set { self[ModelActions.self] = newValue }
  }
}


extension ModelActions: DependencyKey {
  public static let liveValue = {
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.date) var date
    @Dependency(\.rankGeneration) var rankGeneration
    return Self(
      createTodo: { [rankGeneration] todo in
        try database.write { db in
          let maxRank = try Todo
            .select { $0.rank.max() }
            .fetchOne(db) ?? nil
          let newRank = try {
            if let newRank = rankGeneration.midpoint(between: maxRank, and: nil) {
              return newRank
            }
            let todoIds = try Todo
              .select(\.id)
              .order(by: \.rank)
              .fetchAll(db)
            let ranks = rankGeneration.distribute(todoIds.count)
            for (id, rank) in zip(todoIds, ranks) {
              try Todo
                .find(id)
                .update { $0.rank = rank }
                .execute(db)
            }
            guard let newRank = rankGeneration.midpoint(between: ranks.max(), and: nil)
            else { throw ModelActionsError.noRankMidpoint }
            return newRank
          }()
          let rankedTodo = todo.modified { $0.rank = newRank }
          try Todo
            .insert { rankedTodo }
            .execute(db)
        }
      },
      completeTodo: { todoID in
        try database.write { db in
          guard let todo = try Todo
            .find(todoID)
            .fetchOne(db) else { return }
          if let deadline = todo.deadline, let frequencyUnit = todo.frequencyUnit, let frequencyCount = todo.frequencyCount {
            let newDeadline = try deadline.nextFutureDate(
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
              .update { $0.completeDate = date.now }
              .execute(db)
          }
        }
      },
      deleteTodo: { todoID in
        try database.write { db in
          try Todo
            .find(todoID)
            .update { $0.deleteDate = date.now }
            .execute(db)
        }
      },
      putBackTodo: { todoID in
        try database.write { db in
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
        try database.write { db in
          try Todo
            .find(todoID)
            .delete()
            .execute(db)
        }
      },
      moveTodo: { todoID, listID in
        try database.write { db in
          try Todo
            .find(todoID)
            .update { $0.listID = listID }
            .execute(db)
        }
      },
      createList: { list in
        try database.write { db in
          try TodoList
            .insert { list }
            .execute(db)
        }
      },
      updateList: { listID, listName, listColor in
        try database.write { db in
          try TodoList
            .find(listID)
            .update {
              $0.name = listName
              $0.color = listColor
            }
            .execute(db)
        }
      },
      deleteList: { listID in
        try database.write { db in
          try Todo
            .where { $0.listID.eq(listID) }
            .delete()
            .execute(db)
          try TodoList
            .find(listID)
            .delete()
            .execute(db)
        }
      },
      transitionTodo: { todoID, transition in
        try database.write { db in
          try Todo
            .find(todoID)
            .update { $0.transition = transition }
            .execute(db)
        }
      },
      finalizeTransitions: {
        try database.write { db in
          let transitioningTodos = try Todo
            .where { $0.transition.isNot(nil) }
            .fetchAll(db)
          for todo in transitioningTodos {
            if todo.transition == .complete {
              if let deadline = todo.deadline, let frequencyUnit = todo.frequencyUnit, let frequencyCount = todo.frequencyCount {
                let newDeadline = try deadline.nextFutureDate(
                  unit: frequencyUnit,
                  count: frequencyCount
                )
                try Todo
                  .find(todo.id)
                  .update {
                    $0.deadline = newDeadline
                    $0.transition = nil
                  }
                  .execute(db)
              } else {
                try Todo
                  .find(todo.id)
                  .update {
                    $0.completeDate = date.now
                    $0.transition = nil
                  }
                  .execute(db)
              }
            } else if todo.transition == .putBack {
              try Todo
                .find(todo.id)
                .update {
                  $0.completeDate = nil
                  $0.deleteDate = nil
                  $0.transition = nil
                }
                .execute(db)
            }
          }
        }
      },
    )
  }()
  
  public static let testValue = liveValue
}


extension Date {
  func nextFutureDate(
    unit: FrequencyUnit,
    count: Int
  ) throws -> Date {
    if count <= 0 { return self }
    guard let unit = unit.calendarComponent
    else { throw ModelActionsError.invalidFrequency }
    @Dependency(\.date) var date
    let calendar = Calendar.current
    guard let difference = calendar
      .dateComponents([unit], from: self, to: date.now)
      .value(for: unit)
    else { return self }
    let steps = Swift.max(1, (difference / count) + 1)
    return calendar.date(byAdding: unit, value: steps * count, to: self) ?? self
  }
}
