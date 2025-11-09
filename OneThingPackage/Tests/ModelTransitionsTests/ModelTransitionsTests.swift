import CustomDump
import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import StructuredQueries
import Testing

import AppDatabase
import AppModels
@testable import ModelTransitions
import ModelActions
import TestSupport


@MainActor
struct ModelTransitionsTests {
  
  @Test(arguments: [false, true], [false, true])
  func setTransition(old: Bool, new: Bool) async throws {
    let clock = TestClock()
    let createDate = Date(timeIntervalSince1970: 0)
    let completeDate = Date(timeIntervalSince1970: 1)
    let model = prepareTest(ModelTransitions()) {
      TodoListData {
        TodoData(createDate: createDate, isTransitioning: old)
        TodoData(createDate: createDate, isTransitioning: true)
        TodoData(createDate: createDate, isTransitioning: false)
      }
    } dependencies: {
      $0.continuousClock = clock
      $0.date.now = completeDate
    }
    await runAction(model) {
      model.setTransition(1, to: new)
    } change: {
      $0.todos[0].isTransitioning = new
    }
    await runAction(model) {
      await clock.advance(by: .seconds(2))
    } change: {
      $0.todos[0].completeDate = new ? completeDate : nil
      $0.todos[0].isTransitioning = false
      $0.todos[1].completeDate = completeDate
      $0.todos[1].isTransitioning = false
    }
  }
  
//  @Test func toggleCompleteCanceled() async throws {
//    // setup
//    @Dependency(\.defaultDatabase) var database
//    @Dependency(\.continuousClock) var clock
//    let testClock = clock as! TestClock<Duration>
//    try ModelActions.testValue.seedDatabase([
//      TodoList.Draft()
//    ], [
//      Todo.Draft(rank: "0", listID: 1)
//    ])
//    // begin test
//    var model = ModelTransitions()
//    model.toggleComplete(1, complete: true)
//    let didTransition = try await database.read { db in
//      try Todo
//        .find(1)
//        .select(\.isTransitioning)
//        .fetchOne(db)!
//    }
//    #expect(didTransition)
//    model.toggleComplete(1, complete: false)
//    await testClock.advance(by: .seconds(2))
//    try await database.read { db in
//      let (completeDate, isTransitioning) = try Todo
//        .find(1)
//        .select { ($0.completeDate, $0.isTransitioning) }
//        .fetchOne(db)!
//      #expect(completeDate == nil)
//      #expect(isTransitioning == false)
//    }
//  }
//  
//  @Test func testPutBackTimerTask() async throws {
//    // setup
//    @Dependency(\.defaultDatabase) var database
//    @Dependency(\.continuousClock) var clock
//    let testClock = clock as! TestClock<Duration>
//    try ModelActions.testValue.seedDatabase([
//      TodoList.Draft()
//    ], [
//      Todo.Draft(rank: "0", listID: 1),
//      Todo.Draft(rank: "1", listID: 1)
//    ])
//    // begin test
//    var model = ModelTransitions()
//    model.toggleComplete(1, complete: true)
//    model.toggleComplete(2, complete: true)
//    await testClock.advance(by: .seconds(1))
//    model.toggleComplete(2, complete: false)
//    try await database.read { db in
//      let (complete1, transition1) = try Todo
//        .find(1)
//        .select { ($0.completeDate, $0.isTransitioning) }
//        .fetchOne(db)!
//      let (complete2, transition2) = try Todo
//        .find(2)
//        .select { ($0.completeDate, $0.isTransitioning) }
//        .fetchOne(db)!
//      #expect(complete1 == nil)
//      #expect(complete2 == nil)
//      #expect(transition1 == true)
//      #expect(transition2 == false)
//    }
//    await testClock.advance(by: .seconds(2))
//    try await database.read { db in
//      let (complete1, transition1) = try Todo
//        .find(1)
//        .select { ($0.completeDate, $0.isTransitioning) }
//        .fetchOne(db)!
//      let (complete2, transition2) = try Todo
//        .find(2)
//        .select { ($0.completeDate, $0.isTransitioning) }
//        .fetchOne(db)!
//      #expect(complete1 == Date(timeIntervalSince1970: 0))
//      #expect(complete2 == nil)
//      #expect(transition1 == false)
//      #expect(transition2 == false)
//    }
//  }
}
