import SQLiteData
import Testing

@testable import Schema


struct TodoListTests {

  @Test
  func testPreset() async throws {
    let l = TodoList.preset()
    #expect(l.id == 1)
    #expect(l.name == "")
    #expect(l.colorIndex == 0)
    #expect(l.createDate == l.modifyDate)
  }
}
