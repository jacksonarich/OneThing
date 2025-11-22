import AppModels
import Foundation
@testable import ModelActions
import Testing
import TestSupport


struct ListTests {
  
  @Test
  func createList() async throws {
    await prepareTest {
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.createList(TodoList.Draft())
      } assert: {
        $0.lists = [TodoList(id: 1, createDate: Date(1), modifyDate: Date(1))]
      }
    }
  }
  
  @Test
  func deleteList() async throws {
    await prepareTest {
      TodoListData()
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.deleteList(1)
      } assert: {
        $0.lists = []
      }
    }
  }
  
  @Test
  func editList() async throws {
    await prepareTest {
      TodoListData()
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.editList(1, "Name", .yellow)
      } assert: {
        $0.lists[0].name = "Name"
        $0.lists[0].color = .yellow
      }
    }
  }
}
