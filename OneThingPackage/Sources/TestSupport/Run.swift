import AppDatabase
import AppModels
import CustomDump
import Dependencies
import Foundation
import SQLiteData
import Testing

public func runAction<Model: AnyObject>(
  _ model: Model,
  action: @MainActor () async -> Void,
  change: @Sendable (inout DatabaseSnapshot) -> Void,
  fileID: StaticString = #fileID,
  filePath: StaticString = #filePath,
  line: UInt = #line,
  column: UInt = #column
) async {
  do {
    try await withDependencies(from: model) {
      var expected = try DatabaseSnapshot.fetch()
      change(&expected)
      await action()
      let actual = try DatabaseSnapshot.fetch()
      expectNoDifference(
        expected,
        actual,
        fileID: fileID,
        filePath: filePath,
        line: line,
        column: column
      )
    }
  } catch {
    reportIssue(error, fileID: fileID, filePath: filePath, line: line, column: column)
  }
}


public struct DatabaseSnapshot: Equatable, Sendable {
  public var lists: [TodoList]
  public var todos: [Todo]
  
  static func fetch() throws -> Self {
    @Dependency(\.defaultDatabase) var connection
    return try connection.read { db in
      try DatabaseSnapshot(
        lists: TodoList.all.fetchAll(db),
        todos: Todo.all.fetchAll(db)
      )
    }
  }
}
