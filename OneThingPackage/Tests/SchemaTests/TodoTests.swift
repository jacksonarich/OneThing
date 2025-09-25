import AppDatabase
import Dependencies
import DependenciesTestSupport
import Foundation
import Presets
import SQLiteData
import Testing

@testable import Schema

@Suite(
  .dependency(\.continuousClock, ImmediateClock()),
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.uuid, .incrementing),
  .dependency(\.date.now, Date(timeIntervalSince1970: 0))
)
struct TodoTests {
  
  @Test
  func testSearch() async throws {
    let t1 = Todo.Draft.preset(title: "Bell pepper", order: "", listID: 1)
    #expect(t1.search(""))
    #expect(t1.search(" "))
    #expect(t1.search("bell"))
    #expect(t1.search("PEPPER"))
    #expect(!t1.search("  "))
    #expect(!t1.search("banana"))
    let t2 = Todo.Draft.preset(title: "", order: "", listID: 1)
    #expect(t2.search(""))
    #expect(!t2.search("x"))
  }
}
