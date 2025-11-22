import AppModels
import Dependencies
@testable import ListDetail
import Testing
import TestSupport


@MainActor
struct ListDetailTests {
  
  @Test
  func todoRowTapped() async {
    await prepareTest {
      TodoListData {
        TodoData()
      }
    } dependencies: {
      $0.continuousClock = ImmediateClock()
    } test: {
      let model = ListDetailModel(listID: 1)
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
      let model = ListDetailModel(listID: 1)
      await runAction {
        model.editTodo(1)
        #expect(model.editingTodoID == 1)
      }
    }
  }
  
  @Test
  func newTodoButtonTapped() async {
    await prepareTest {
      TodoListData {
        TodoData()
      }
    } test: {
      let model = ListDetailModel(listID: 1)
      await runAction {
        model.newTodoButtonTapped()
        #expect(model.isCreatingTodo == true)
      }
    }
  }
  
  @Test
  func rerankTodos() async {
    await prepareTest {
      TodoListData {
        TodoData()
        TodoData()
        TodoData()
      }
    } dependencies: {
      $0.modelActions.rerankTodos = { sourceIds, targetId in
        #expect(sourceIds == [1, 2])
        #expect(targetId == nil)
      }
    } test: {
      let model = ListDetailModel(listID: 1)
      await runAction {
        model.rerankTodos([0, 1], 3)
      }
    }
  }
  
  @Test
  func rerankTodosWithTarget() async {
    await prepareTest {
      TodoListData {
        TodoData()
        TodoData()
        TodoData()
      }
    } dependencies: {
      $0.modelActions.rerankTodos = { sourceIds, targetId in
        #expect(sourceIds == [1])
        #expect(targetId == 3)
      }
    } test: {
      let model = ListDetailModel(listID: 1)
      await runAction {
        model.rerankTodos([0], 2)
      }
    }
  }
}
