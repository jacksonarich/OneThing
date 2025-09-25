import Dependencies
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
  
  public init(
    id: ID,
    title: String,
    notes: String,
    deadline: Date?,
    frequencyUnitIndex: Int?,
    frequencyCount: Int?,
    createDate: Date,
    modifyDate: Date,
    completeDate: Date?,
    deleteDate: Date?,
    order: String,
    listID: TodoList.ID
  ) {
    self.id = id
    self.title = title
    self.notes = notes
    self.deadline = deadline
    self.frequencyUnitIndex = frequencyUnitIndex
    self.frequencyCount = frequencyCount
    self.createDate = createDate
    self.modifyDate = modifyDate
    self.completeDate = completeDate
    self.deleteDate = deleteDate
    self.order = order
    self.listID = listID
  }
}

extension Todo.Draft: Equatable {}

public extension Todo {
  /// Primary key.
  typealias ID = Int
  /// True iff `title` contains the given text, case insensitive.
  func search(_ text: String) -> some QueryExpression<Bool> {
    text.isEmpty
    || title.lowercased().contains(text.lowercased())
  }
}
public extension Todo.Draft {
  /// True iff `title` contains the given text, case insensitive.
  func search(_ text: String) -> Bool {
    text.isEmpty
    || title.lowercased().contains(text.lowercased())
  }
}
public extension Todo.TableColumns {
  /// True iff `title` contains the given text, case insensitive.
  func search(_ text: String) -> some QueryExpression<Bool> {
    text.isEmpty
    || title.lower().contains(text.lowercased())
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
