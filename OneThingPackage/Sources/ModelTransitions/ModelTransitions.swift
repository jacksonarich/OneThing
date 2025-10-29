// Interface used by view models to write to the database.


import SQLiteData
import StructuredQueriesCore
import SwiftUI

import AppModels
import ModelActions


public struct Transitions: Equatable {
  private let phase1: Dictionary<Todo.ID, Date?>.Keys
  private let phase2: Set<Todo.ID>
  
  internal init(phase1: Dictionary<Todo.ID, Date?>.Keys, phase2: Set<Todo.ID>) {
    self.phase1 = phase1
    self.phase2 = phase2
  }
  
  public init() {
    self.phase1 = [Todo.ID: Date?]().keys
    self.phase2 = []
  }
}

extension Transitions {
  public func isVisible(
    _ todoID: SQLiteData.TableColumn<Todo.TableColumns.QueryValue, Todo.ID>,
    predicate: some QueryExpression<Bool>
  ) -> some QueryExpression<Bool> {
    phase1.contains(todoID)
      .or(
        phase2.contains(todoID).not()
          .and(predicate)
      )
  }
}

extension ModelTransitions {
  public var transitions: Transitions {
    .init(phase1: phaseOneIDs.keys, phase2: phaseTwoIDs)
  }
}

@MainActor
public class ModelTransitions {
  
  @Dependency(\.modelActions)
  private var modelActions
  
  @Dependency(\.continuousClock)
  private var clock
  
  public private(set) var phaseOneIDs: [Todo.ID : Date?] = [:]
  
  public private(set) var phaseTwoIDs: Set<Todo.ID> = []
    
  private(set) var transitionTask: Task<Void, Never>? = nil
  
  private(set) var updateQuery: () async -> ()
  
  // p1  | p2  | visible
  // ––––+–––––+––––––––
  // yes | yes | yes
  // yes | no  | yes
  // no  | yes | no
  // no  | no  | depends on query
  public func isVisible(
//    _ todoID: Todo.ID,
    _ todoID: SQLiteData.TableColumn<Todo.TableColumns.QueryValue, Todo.ID>,
    wrapping predicate: some QueryExpression<Bool>
  ) -> some QueryExpression<Bool> {
    phaseOneIDs.keys.contains(todoID)
    .or(
      phaseTwoIDs.contains(todoID).not()
      .and(predicate)
    )
  }
  
  // In Progress
  // - complete (non-recurring)
  //   - cancel transition task
  //   - mark todo as phase 1 with oldDeadline == nil
  //   - update query
  //   - modelActions.completeTodo
  //   - set transition task
  // - complete (recurring)
  //   - cancel transition task
  //   - mark todo as phase 1 with oldDeadline != nil
  //   - update query
  //   - modelActions.completeTodo
  //   - set transition task
  // - put back (non-recurring)
  //   - cancel transition task
  //   - capture oldDeadline
  //   - mark todo as phase 1 with oldDeadline == nil
  //   - update query
  //   - value == .some(nil)   [non-recurring, can't be first tap]
  //   - modelActions.putBackTodo
  //   - set transition task
  // - put back (recurring)
  //   - cancel transition task
  //   - capture oldDeadline
  //   - mark todo as phase 1 with oldDeadline == nil
  //   - update query
  //   - value == .some(Date)   [recurring, can't be first tap]
  //   - modelActions.unrescheduleTodo
  //   - set transition task
  // Completed
  // - put back (non-recurring)
  //   - cancel transition task
  //   - capture oldDeadline
  //   - mark todo as phase 1 with oldDeadline == nil
  //   - update query
  //   - value == nil OR .some(nil)   [non-recurring, might be first tap]
  //   - modelActions.putBackTodo
  //   - set transition task
  // - put back (recurring)
  //   - cancel transition task
  //   - capture oldDeadline
  //   - mark todo as phase 1 with oldDeadline == nil
  //   - update query
  //   - value == nil OR .some(Date)   [recurring, might be first tap]
  //   - modelActions.unrescheduleTodo
  //   - set transition task
  
  
  public func completeTodo(_ todo: Todo, undo: Bool = false) {
    transitionTask?.cancel()
    if undo {
      phaseOneIDs.removeValue(forKey: todo.id)
    } else {
      let isRecurring = todo.deadline != nil && todo.frequencyUnitIndex != nil && todo.frequencyCount != nil
      let oldDeadline = isRecurring ? todo.deadline : nil
      phaseOneIDs.updateValue(oldDeadline, forKey: todo.id)
    }
    Task {
      await updateQuery()
      try modelActions.completeTodo(todo.id)
    }
    setTransitionTask()
  }
  
  public func deleteTodo(_ todo: Todo, undo: Bool = false) {
    transitionTask?.cancel()
    if undo {
      phaseOneIDs.removeValue(forKey: todo.id)
    } else {
      phaseOneIDs.updateValue(nil, forKey: todo.id)
    }
    Task {
      await updateQuery()
      try modelActions.deleteTodo(todo.id)
    }
    setTransitionTask()
  }
  
  public func putBackTodo(_ todo: Todo, undo: Bool = false) {
    transitionTask?.cancel()
    let value = phaseOneIDs[todo.id]
    if undo {
      phaseOneIDs.removeValue(forKey: todo.id)
    } else {
      phaseOneIDs.updateValue(nil, forKey: todo.id)
    }
    Task {
      await updateQuery()
      if let value, let oldDeadline = value { // in phase 1 AND is recurring
        try modelActions.unrescheduleTodo(todo.id, oldDeadline)
      } else {
        try modelActions.putBackTodo(todo.id)
      }
    }
    setTransitionTask()
  }
  
  private func setTransitionTask() {
    transitionTask = Task {
      await withErrorReporting {
        try await clock.sleep(for: .seconds(2))
        phaseTwoIDs.formUnion(phaseOneIDs.keys)
        phaseOneIDs.removeAll()
        await updateQuery()
        try await clock.sleep(for: .seconds(2))
        phaseTwoIDs.removeAll()
        await updateQuery()
      }
    }
  }
  
  public init(
    updateQuery: @escaping () async -> ()
  ) {
    self.updateQuery = updateQuery
  }
}
