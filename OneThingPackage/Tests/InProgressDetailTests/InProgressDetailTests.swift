import AppModels
import Dependencies
@testable import InProgressDetail
import Testing
import TestSupport


@MainActor
struct InProgressDetailTests {
  
  @Test
  func todoRowTapped() async {
    await prepareTest {
      TodoListData {
        TodoData()
      }
    } dependencies: {
      $0.continuousClock = ImmediateClock()
    } test: {
      let model = InProgressDetailModel()
      await runAction {
        model.todoRowTapped(1, shouldTransition: true)
        #expect(model.hapticID == 1)
      } assert: {
        $0.todos[0].transition = .complete
      }
    }
  }
  
  @Test
  func editTodo() async {
    await prepareTest {
      TodoListData {
        TodoData()
      }
    } test: {
      let model = InProgressDetailModel()
      await runAction {
        model.editTodo(1)
        #expect(model.editingTodoID == 1)
      }
    }
  }
}
