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
  public var rerankTodos: @Sendable ([Todo.ID], Todo.ID?) throws -> Void
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
//            let todoIds = try Todo
//              .select(\.id)
//              .order(by: \.rank)
//              .fetchAll(db)
//            let ranks = rankGeneration.distribute(todoIds.count)
//            for (id, rank) in zip(todoIds, ranks) {
//              try Todo
//                .find(id)
//                .update { $0.rank = rank }
//                .execute(db)
//            }
//            guard let newRank = rankGeneration.midpoint(between: ranks.max(), and: nil)
//            else { throw ModelActionsError.noRankMidpoint }
//            return newRank
            throw ModelActionsError.noRankMidpoint
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
      rerankTodos: { todoIDs, targetID in
        // receive N ordered todos to rerank
        // upper bound = todos[targetIndex].rank
        // while todos[ub] is being moved: ub += 1
        // lower bound = todos[targetIndex - 1].rank
        // while todos[lb] is being moved: lb -= 1
        // generate N ranks between lower and upper bounds, in order
        // if generation failed due to adjacent ranks, redistribute ranks and go back to step 1
        // assign ranks to todos
        try database.write { db in
          var rightID = targetID
          var rightRank: Rank?
          if let targetID {
            let rank = try Todo
              .find(targetID)
              .select(\.rank)
              .fetchOne(db)!
            // Default to using `rightBound`'s rank
            rightRank = rank
            if todoIDs.contains(targetID) {
              // If `rightBound` is being moved, find the next todo in rank order
              let realRight = try Todo
                .select { ($0.id, $0.rank) }
                .where { $0.id.in(todoIDs).not() }
                .where { $0.rank.gt(rank) }
                .order { $0.rank.asc() }
                .limit(1)
                .fetchOne(db)
              rightID = realRight?.0
              rightRank = realRight?.1
            }
          }
          var leftID: Todo.ID?
          if let rightRank {
            let left = try Todo
              .select(\.id)
              .where { $0.rank.lt(rightRank) }
              .where { $0.id.in(todoIDs).not() }
              .order { $0.rank.desc() }
              .limit(1)
              .fetchOne(db)
            leftID = left
          } else {
            let left = try Todo
              .select(\.id)
              .where { $0.id.in(todoIDs).not() }
              .order { $0.rank.desc() }
              .limit(1)
              .fetchOne(db)
            leftID = left
          }
          let ranks = try db.createRanks(
            count: todoIDs.count,
            between: leftID,
            and: rightID
          )
          for (todoID, rank) in zip(todoIDs, ranks) {
            try Todo
              .find(todoID)
              .update { $0.rank = rank }
              .execute(db)
          }
//          var upperRank: Rank?
//          var lowerRank: Rank?
//          if let targetID {
//            let targetRank = try Todo
//              .find(targetID)
//              .select(\.rank)
//              .fetchOne(db)!
//            upperRank = try Todo
//              .select { $0.rank }
//              .where {
//                $0.rank.gte(targetRank)
//                .and($0.id.in(todoIDs).not())
//              }
//              .order { $0.rank.asc() }
//              .limit(1)
//              .fetchOne(db)
//            lowerRank = try Todo
//              .select { $0.rank }
//              .where {
//                $0.rank.lt(targetRank)
//                .and($0.id.in(todoIDs).not())
//              }
//              .order { $0.rank.desc() }
//              .limit(1)
//              .fetchOne(db)
//          } else {
//            // end of list
//            
//          }
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


extension Database {
  fileprivate func createRanks(
    count: Int,
    between left: Todo.ID?,
    and right: Todo.ID?,
    rebalanced: Bool = false
  ) throws -> [Rank] {
    guard count > 0 else { return [] }
    func rank(for id: Todo.ID?) throws -> Rank? {
      guard let id else { return nil }
      return try Todo
        .find(id)
        .select(\.rank)
        .fetchOne(self)
    }
    let leftRank = try rank(for: left)
    let rightRank = try rank(for: right)
    
    @Dependency(\.rankGeneration) var rankGeneration
    var ranks = [Rank]()
    ranks.reserveCapacity(count)
    var current = leftRank
    for _ in 0..<count {
      guard let next = rankGeneration.midpoint(between: current, and: rightRank) else {
        if rebalanced {
          throw ModelActionsError.noRankMidpoint
        }
        try rebalanceRanks()
        return try createRanks(
          count: count,
          between: left,
          and: right,
          rebalanced: true
        )
      }
      ranks.append(next)
      current = next
    }
    return ranks
  }
  
  @discardableResult
  func rebalanceRanks() throws -> [Rank] {
    @Dependency(\.rankGeneration) var rankGeneration
    let todoIds = try Todo
      .select(\.id)
      .order(by: \.rank)
      .fetchAll(self)
    let ranks = rankGeneration.distribute(todoIds.count)
    for (todoId, rank) in zip(todoIds, ranks) {
      try Todo
        .find(todoId)
        .update {
          $0.rank = rank
        }
        .execute(self)
    }
    return ranks
  }
}
