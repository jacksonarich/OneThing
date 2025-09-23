import Foundation
import SQLiteData
import StructuredQueries
import SwiftUI


@Table
public struct Todo: Identifiable, Equatable, Sendable {
  public let id:                 ID
  public let title:              String
  public let notes:              String
  public let deadline:           Date?
  public let frequencyUnitIndex: Int?
  public let frequencyCount:     Int?
  public let createDate:         Date
  public let modifyDate:         Date
  public let completeDate:       Date?
  public let deleteDate:         Date?
  public let order:              String
  public let listID:             TodoList.ID
}


public extension Todo {
  /// Primary key.
  typealias ID = Int
  /// True iff `title` contains the given text, case insensitive.
  func search(_ text: String) -> Bool {
    text.isEmpty
    || title.lowercased().contains(text.lowercased())
  }
  /// True iff `completeDate` is not nil.
  var isCompleted: Bool {
    completeDate != nil
  }
  /// True iff `deleteDate` is not nil.
  var isDeleted: Bool {
    deleteDate != nil
  }
  /// True iff neither completed nor deleted.
  var isInProgress: Bool {
    completeDate == nil
    && deleteDate == nil
  }
  /// True iff in progress and `deadline` is not nil.
  var isScheduled: Bool {
    isInProgress
    && deadline != nil
  }
  /// Shortcut initializer for use in testing.
  static func preset(
    id:                 Todo.ID     = 1,
    title:              String      = "",
    notes:              String      = "",
    deadline:           Date?       = nil,
    frequencyUnitIndex: Int?        = nil,
    frequencyCount:     Int?        = nil,
    createDate:         Date        = .now,
    modifyDate:         Date        = .now,
    completeDate:       Date?       = nil,
    deleteDate:         Date?       = nil,
    order:              String      = "",
    listID:             TodoList.ID = 1
  ) -> Todo.Draft {
    .init(
      id:                 id,
      title:              title,
      notes:              notes,
      deadline:           deadline,
      frequencyUnitIndex: frequencyUnitIndex,
      frequencyCount:     frequencyCount,
      createDate:         createDate,
      modifyDate:         modifyDate,
      completeDate:       completeDate,
      deleteDate:         deleteDate,
      order:              order,
      listID:             listID
    )
  }
}


public extension Todo.TableColumns {
  /// True iff `title` contains the given text, case insensitive.
  func search(_ text: String) -> some QueryExpression<Bool> {
    text.isEmpty
    || title.lower().contains(text.lowercased())
  }
  /// True iff `completeDate` is not nil.
  var isCompleted: some QueryExpression<Bool> {
    completeDate != nil
  }
  /// True iff `deleteDate` is not nil.
  var isDeleted: some QueryExpression<Bool> {
    deleteDate != nil
  }
  /// True iff neither completed nor deleted.
  var isInProgress: some QueryExpression<Bool> {
    completeDate == nil
    && deleteDate == nil
  }
  /// True iff in progress and `deadline` is not nil.
  var isScheduled: some QueryExpression<Bool> {
    isInProgress
    && deadline != nil
  }
}


public extension Calendar.Component {
  /// Corresponds to `Todo.frequencyUnitIndex`.
  static let all: [Self] = [
    .day,
    .weekOfYear,
    .month,
    .year
  ]
}
