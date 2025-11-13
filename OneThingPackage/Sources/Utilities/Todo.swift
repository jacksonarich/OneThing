import AppModels
import Dependencies
import Foundation
import SQLiteData
import StructuredQueries
import SwiftUI


public extension Todo {
  var isOverdue: Bool {
    guard let deadline else { return false }
    @Dependency(\.date) var date
    return deadline < date.now
  }
}


public extension Todo.Draft {
  func modified(_ body: (inout Todo.Draft) -> Void) -> Todo.Draft {
    var copy = self
    body(&copy)
    return copy
  }
}


public extension Todo.TableColumns {
  func contains(_ text: String) -> some QueryExpression<Bool> {
    title.lower().contains(text.lowercased())
  }
  var isCompleted: some QueryExpression<Bool> {
    completeDate.isNot(nil)
  }
  var isDeleted: some QueryExpression<Bool> {
    deleteDate.isNot(nil)
  }
  var isInProgress: some QueryExpression<Bool> {
    completeDate.is(nil)
    .and(deleteDate.is(nil))
  }
  var isScheduled: some QueryExpression<Bool> {
    isInProgress
    .and(deadline.isNot(nil))
  }
}
