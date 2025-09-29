// Utility functions relating to `Todo` and its variants.

import Dependencies
import Foundation
import SQLiteData
import StructuredQueries
import SwiftUI

import Schema


public extension Todo {
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


public extension Todo.TableColumns {
  func contains(_ text: String) -> some QueryExpression<Bool> {
    title.lower().contains(text.lowercased())
  }
  var isCompleted: some QueryExpression<Bool> {
    completeDate != nil
  }
  var isDeleted: some QueryExpression<Bool> {
    deleteDate != nil
  }
  var isInProgress: some QueryExpression<Bool> {
    completeDate == nil && deleteDate == nil
  }
  var isScheduled: some QueryExpression<Bool> {
    isInProgress && deadline != nil
  }
}
