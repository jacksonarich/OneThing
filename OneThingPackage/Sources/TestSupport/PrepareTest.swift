import AppDatabase
import AppModels
import Dependencies
import Foundation
import Testing

public func prepareTest<Model: AnyObject>(
  _ model: @autoclosure () -> Model,
  @TodoListBuilder database: () -> [TodoListData],
  dependencies prepareDependencies: (inout DependencyValues) -> Void = { _ in },
  sourceLocation: SourceLocation = #_sourceLocation
) -> Model {
  withDependencies {
    do {
      $0.date.now = Date(timeIntervalSince1970: 0)
      $0.defaultDatabase = try appDatabase(data: AppData(lists: database))
      prepareDependencies(&$0)
    } catch {
      Issue.record(error, sourceLocation: sourceLocation)
    }
  } operation: {
    return model()
  }
}
