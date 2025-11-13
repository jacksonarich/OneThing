import AppDatabase
import AppModels
import Dependencies
import Foundation
import Testing


//@MainActor
public func prepareTest(
  @TodoListBuilder data: @Sendable () -> [TodoListData],
  dependencies: @Sendable (inout DependencyValues) -> Void = { _ in },
  test: @MainActor () async throws -> Void,
  sourceLocation: SourceLocation = #_sourceLocation
) async {
  do {
    let database = try withDependencies {
      $0.date.now = Date(0)
    } operation: {
      return try appDatabase(data: AppData(lists: data))
    }
    try await withDependencies {
      $0.date.now = Date(1)
      $0.defaultDatabase = database
      dependencies(&$0)
    } operation: {
      try await test()
    }
  } catch {
    Issue.record(error, sourceLocation: sourceLocation)
  }
}


// was working on this last night, found that my prepareDependencies solution doesn't work with parameterized tests (GPT convo)
// decided to just use withDependencies and put the entire test in a closure passed to prepareTest
// the concept does seem to work, but ended up adding a bunch of stuff to the prepareTest parameters, like async, throws, @Sendable, @MainActor
// need to figure out how much of that stuff can be removed
