import CustomDump
import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import StructuredQueries
import Testing

import AppDatabase
@testable import ModelTransitions
import ModelActions
import AppModels


@MainActor
@Suite(
  .dependency(\.continuousClock, TestClock()),
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.date.now, Date(timeIntervalSince1970: 0))
)
struct ModelTransitionsTests {
  
  @Test
  func toggleComplete() async throws {
    // setup
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.continuousClock) var clock
    let testClock = clock as! TestClock<Duration>
    try ModelActions.testValue.seedDatabase([
      TodoList.Draft()
    ], [
      Todo.Draft(rank: "0", listID: 1)
    ])
    // begin test
    var m = ModelTransitions()
    m.toggleComplete(1, complete: true)
    let didTransition = try await database.read { db in
      try Todo
        .find(1)
        .select(\.isTransitioning)
        .fetchOne(db)!
    }
    #expect(didTransition)
    await testClock.advance(by: .seconds(2))
    try await database.read { db in
      let (completeDate, isTransitioning) = try Todo
        .find(1)
        .select { ($0.completeDate, $0.isTransitioning) }
        .fetchOne(db)!
      #expect(completeDate == Date(timeIntervalSince1970: 0))
      #expect(isTransitioning == false)
    }
  }
  
  @Test func toggleCompleteCanceled() async throws {
    // setup
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.continuousClock) var clock
    let testClock = clock as! TestClock<Duration>
    try ModelActions.testValue.seedDatabase([
      TodoList.Draft()
    ], [
      Todo.Draft(rank: "0", listID: 1)
    ])
    // begin test
    var model = ModelTransitions()
    model.toggleComplete(1, complete: true)
    let didTransition = try await database.read { db in
      try Todo
        .find(1)
        .select(\.isTransitioning)
        .fetchOne(db)!
    }
    #expect(didTransition)
    model.toggleComplete(1, complete: false)
    await testClock.advance(by: .seconds(2))
    try await database.read { db in
      let (completeDate, isTransitioning) = try Todo
        .find(1)
        .select { ($0.completeDate, $0.isTransitioning) }
        .fetchOne(db)!
      #expect(completeDate == nil)
      #expect(isTransitioning == false)
    }
  }
  
  @Test func testPutBackTimerTask() async throws {
    // setup
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.continuousClock) var clock
    let testClock = clock as! TestClock<Duration>
    try ModelActions.testValue.seedDatabase([
      TodoList.Draft()
    ], [
      Todo.Draft(rank: "0", listID: 1),
      Todo.Draft(rank: "1", listID: 1)
    ])
    // begin test
    var model = ModelTransitions()
    model.toggleComplete(1, complete: true)
    model.toggleComplete(2, complete: true)
    await testClock.advance(by: .seconds(1))
    model.toggleComplete(2, complete: false)
    try await database.read { db in
      let (complete1, transition1) = try Todo
        .find(1)
        .select { ($0.completeDate, $0.isTransitioning) }
        .fetchOne(db)!
      let (complete2, transition2) = try Todo
        .find(2)
        .select { ($0.completeDate, $0.isTransitioning) }
        .fetchOne(db)!
      #expect(complete1 == nil)
      #expect(complete2 == nil)
      #expect(transition1 == true)
      #expect(transition2 == false)
    }
    await testClock.advance(by: .seconds(2))
    try await database.read { db in
      let (complete1, transition1) = try Todo
        .find(1)
        .select { ($0.completeDate, $0.isTransitioning) }
        .fetchOne(db)!
      let (complete2, transition2) = try Todo
        .find(2)
        .select { ($0.completeDate, $0.isTransitioning) }
        .fetchOne(db)!
      #expect(complete1 == Date(timeIntervalSince1970: 0))
      #expect(complete2 == nil)
      #expect(transition1 == false)
      #expect(transition2 == false)
    }
  }
}
