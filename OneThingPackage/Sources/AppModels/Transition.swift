import Foundation
import SQLiteData

@Table
public struct Transition {
  @Column(primaryKey: true)
  public let todoID: Todo.ID
//  public var phase: Phase
//  public var oldDeadline: Date?
  
  public init(
    todoID: Todo.ID,
//    phase: Phase,
//    oldDeadline: Date? = nil
  ) {
    self.todoID = todoID
//    self.phase = phase
//    self.oldDeadline = oldDeadline
  }
}

//public struct Phase: RawRepresentable, QueryBindable, Sendable {
//  public var rawValue: String
//  public init(rawValue: String) { self.rawValue = rawValue }
//  
//  public static let phase1 = Phase(rawValue: "phase1")
//  public static let phase2 = Phase(rawValue: "phase2")
//}
