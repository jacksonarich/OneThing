import BaseTestSuite
import Schema
import SQLiteData
import Testing

@testable import ModelActions


extension BaseTestSuite {
  struct ModelActionsTests {
    
    @Test
    func createTodoList() async throws {
      @FetchAll(TodoList.all) var allLists
      #expect(allLists.count == 0)
      let l = TodoList.preset()
      try ModelActions.liveValue.createList(l)
      try await $allLists.load()
      #expect(allLists.count == 1)
    }
  }
}
