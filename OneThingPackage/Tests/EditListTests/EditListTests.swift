import AppModels
@testable import EditList
import Testing
import TestSupport


@MainActor
struct EditListTests {
  
  @Test
  func showDialog() async {
    await prepareTest {
      TodoListData()
    } test: {
      let model = EditListModel(listID: 1)
      await runAction {
        model.showDialog()
        #expect(model.showAlert == true)
      }
    }
  }

  @Test
  func fetch() async {
    await prepareTest {
      TodoListData(name: "Grocery", color: .indigo)
    } test: {
      let model = EditListModel(listID: 1)
      await runAction {
        model.fetch()
        #expect(model.name == "Grocery")
        #expect(model.color == .indigo)
      }
    }
  }

  @Test
  func fetchInvalidListID() async {
    await prepareTest {
      TodoListData(name: "Grocery", color: .indigo)
    } test: {
      let model = EditListModel(listID: 100, name: "Invalid List", color: .orange)
      await runAction {
        model.fetch()
        #expect(model.name == "Invalid List")
        #expect(model.color == .orange)
      }
    }
  }
}
