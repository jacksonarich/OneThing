import Dependencies
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
  
  public init(id: ID, name: String, colorIndex: Int, createDate: Date, modifyDate: Date) {
    self.id = id
    self.name = name
    self.colorIndex = colorIndex
    self.createDate = createDate
    self.modifyDate = modifyDate
  }
}

extension TodoList.Draft: Equatable {}

public extension TodoList {
  /// Primary key.
  typealias ID = Int
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
