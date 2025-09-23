import SQLiteData
import Testing

@testable import Schema


struct TodoTests {
  
  @Test
  func testPreset() async throws {
    let t = Todo.preset()
    #expect(t.id == 1)
    #expect(t.title == "")
    #expect(t.notes == "")
    #expect(t.deadline == nil)
    #expect(t.frequencyUnitIndex == nil)
    #expect(t.frequencyCount == nil)
    #expect(t.createDate == t.modifyDate)
    #expect(t.completeDate == nil)
    #expect(t.deleteDate == nil)
    #expect(t.order == "")
    #expect(t.listID == 1)
  }

  @Test
  func testSearch() async throws {
    let t1 = Todo.preset(title: "Bell pepper")
    #expect(t1.search(""))
    #expect(t1.search(" "))
    #expect(t1.search("bell"))
    #expect(t1.search("PEPPER"))
    #expect(!t1.search("  "))
    #expect(!t1.search("banana"))
    let t2 = Todo.preset(title: "")
    #expect(t2.search(""))
    #expect(!t2.search("x"))
  }
}
