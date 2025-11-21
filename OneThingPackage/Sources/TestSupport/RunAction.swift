import AppDatabase
import AppModels
import CustomDump
import Dependencies
import Foundation
import SQLiteData
import Testing


public func runAction(
  action: @MainActor () async throws -> Void,
  assert change: @Sendable (inout DatabaseSnapshot) -> Void = { _ in },
  fileID: StaticString = #fileID,
  filePath: StaticString = #filePath,
  line: UInt = #line,
  column: UInt = #column
) async {
  do {
    var expected = try DatabaseSnapshot.fetch()
    change(&expected)
    try await action()
    let actual = try DatabaseSnapshot.fetch()
    expectNoDifference(
      expected,
      actual,
      fileID: fileID,
      filePath: filePath,
      line: line,
      column: column
    )
  } catch {
    reportIssue(error, fileID: fileID, filePath: filePath, line: line, column: column)
  }
}


public struct DatabaseSnapshot: Equatable, Sendable {
  public var lists: [TodoList]
  public var todos: [Todo]
  
  static func fetch() throws -> Self {
    @Dependency(\.defaultDatabase) var database
    return try database.read { db in
      try DatabaseSnapshot(
        lists: TodoList.all.fetchAll(db),
        todos: Todo.all.fetchAll(db)
      )
    }
  }
}
