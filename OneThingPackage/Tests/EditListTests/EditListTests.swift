import AppModels
@testable import EditList
import Testing
import TestSupport

@MainActor
struct EditListTests {
  @Test func showDialog() async {
    await prepareTest {
      TodoListData()
    } test: {
      let model = EditListModel(listID: 1)
      await runAction {
        model.showDialog()
        #expect(model.showAlert == true)
      } assert: { _ in
        // No changes
      }
    }
  }

  @Test func fetch() async {
    await prepareTest {
      TodoListData(name: "Grocery", color: .indigo)
    } test: {
      let model = EditListModel(listID: 1)
      await runAction {
        model.fetch()
        #expect(model.name == "Grocery")
        #expect(model.color == .indigo)
      } assert: { _ in
        // No changes
      }
    }
  }
}
