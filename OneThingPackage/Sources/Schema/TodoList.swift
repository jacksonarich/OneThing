import Foundation
import SQLiteData
import SwiftUI


@Table
public struct TodoList: Identifiable, Equatable, Sendable {
  public let id:         ID
  public let name:       String
  public let colorIndex: Int
  public let createDate: Date
  public let modifyDate: Date
}


public extension TodoList {
  /// Primary key.
  typealias ID = Int
  /// Shortcut initializer for use in testing.
  static func preset(
    id:         TodoList.ID = 1,
    name:       String      = "",
    colorIndex: Int         = 0,
    createDate: Date        = .now,
    modifyDate: Date        = .now
  ) -> TodoList.Draft {
    .init(
      id:         id,
      name:       name,
      colorIndex: colorIndex,
      createDate: createDate,
      modifyDate: modifyDate
    )
  }
}


public extension Color {
  /// Corresponds to `TodoList.colorIndex`.
  static let all: [Self] = [
    .red,
    .orange,
    .yellow,
    .green,
    .cyan,
    .blue,
    .indigo,
    .pink,
    .purple,
    .brown
  ]
}
