import AppModels
@testable import EditTodo
import Foundation
import Testing
import TestSupport


@MainActor
struct EditTodoTests {
  
  @Test(arguments: [false, true])
  func showDialog(isOn: Bool) async {
    await prepareTest {
      TodoListData {
        TodoData()
      }
    } test: {
      let model = EditTodoModel(todoID: 1)
      await runAction {
        model.toggleDeadline(isOn: isOn)
        #expect(model.deadline == (isOn ? Date(1) : nil))
      }
    }
  }
  
  @Test
  func fetchSelectedFrequency() async {
    await prepareTest {
      TodoListData {
        TodoData(title: "Buy milk", notes: "1 gallon lowfat", deadline: Date(2), frequencyUnit: .week, frequencyCount: 1)
      }
    } test: {
      let model = EditTodoModel(todoID: 1)
      await runAction {
        model.fetch()
        #expect(model.listID == 1)
        #expect(model.title == "Buy milk")
        #expect(model.notes == "1 gallon lowfat")
        #expect(model.deadline == Date(2))
        #expect(model.frequencySelection == .weekly)
        #expect(model.customFrequency == .init(unit: .day))
      }
    }
  }
  
  @Test
  func fetchCustomFrequency() async {
    await prepareTest {
      TodoListData {
        TodoData(title: "Buy milk", notes: "1 gallon lowfat", deadline: Date(2), frequencyUnit: .week, frequencyCount: 2)
      }
    } test: {
      let model = EditTodoModel(todoID: 1)
      await runAction {
        model.fetch()
        #expect(model.listID == 1)
        #expect(model.title == "Buy milk")
        #expect(model.notes == "1 gallon lowfat")
        #expect(model.deadline == Date(2))
        #expect(model.frequencySelection == .custom)
        #expect(model.customFrequency == .init(unit: .week, count: 2))
      }
    }
  }
}
