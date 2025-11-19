import AppModels
import Foundation
import ModelActions
import SQLiteData
import Testing
import TestSupport


@MainActor
struct ModelActionsTests {
  
  @Test func createTodo() async throws {
    await prepareTest {
      TodoListData {
        TodoData(rank: "0")
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        let draft = Todo.Draft(listID: 1)
        try model.createTodo(draft)
      } assert: {
        $0.todos.append(Todo(2, listID: 1, rank: "1"))
      }
    }
  }
  
  @Test
  func completeTodo() async throws {
    await prepareTest {
      TodoListData {
        TodoData()
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.completeTodo(1)
      } assert: {
        $0.todos[0].completeDate = Date(1)
      }
    }
  }
  
  @Test
  func rescheduleTodo() async throws {
    await prepareTest {
      TodoListData {
        TodoData(deadline: Date(0), frequencyUnit: .week, frequencyCount: 2)
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.completeTodo(1)
      } assert: {
        $0.todos[0].deadline = Date(60 * 60 * 24 * 7 * 2)
      }
    }
  }
  
  @Test
  func deleteTodo() async throws {
    await prepareTest {
      TodoListData {
        TodoData()
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.deleteTodo(1)
      } assert: {
        $0.todos[0].deleteDate = Date(1)
      }
    }
  }
  
  @Test
  func putBackTodo() async throws {
    await prepareTest {
      TodoListData {
        TodoData(completeDate: Date(0), deleteDate: Date(0))
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.putBackTodo(1)
      } assert: {
        $0.todos[0].completeDate = nil
        $0.todos[0].deleteDate = nil
      }
    }
  }
  
  @Test
  func eraseTodo() async throws {
    await prepareTest {
      TodoListData {
        TodoData(completeDate: Date(0), deleteDate: Date(0))
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.eraseTodo(1)
      } assert: {
        $0.todos = []
      }
    }
  }
  
  @Test
  func moveTodo() async throws {
    await prepareTest {
      TodoListData {
        TodoData()
      }
      TodoListData()
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.moveTodo(1, 2)
      } assert: {
        $0.todos[0].listID = 2
      }
    }
  }
  
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
  
  @Test(arguments: [false, true])
  func transitionTodo(new: Bool) async throws {
    let oldTransition: TransitionAction? = new ? nil : .complete
    let newTransition: TransitionAction? = new ? .complete : nil
    await prepareTest {
      TodoListData {
        TodoData(transition: oldTransition)
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.transitionTodo(1, newTransition)
      } assert: {
        $0.todos[0].transition = newTransition
      }
    }
  }
  
  @Test
  func finalizeTransitionsComplete() async throws {
    await prepareTest {
      TodoListData {
        TodoData()
        TodoData(transition: .complete)
        TodoData(deadline: Date(0), frequencyUnit: .week, frequencyCount: 2, transition: .complete)
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.finalizeTransitions()
      } assert: {
        $0.todos[1].completeDate = Date(1)
        $0.todos[2].deadline = Calendar.current.date(byAdding: .weekOfYear, value: 2, to: Date(0))
        for i in 0...2 {
          $0.todos[i].transition = nil
        }
      }
    }
  }
  
  @Test
  func finalizeTransitionsPutBack() async throws {
    await prepareTest {
      TodoListData {
        TodoData(completeDate: Date(0))
        TodoData(completeDate: Date(0), transition: .putBack)
        TodoData(deleteDate: Date(0), transition: .putBack)
        TodoData(completeDate: Date(0), deleteDate: Date(0), transition: .putBack)
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.finalizeTransitions()
      } assert: {
        for i in 1...3 {
          $0.todos[i].completeDate = nil
          $0.todos[i].deleteDate = nil
          $0.todos[i].transition = nil
        }
      }
    }
  }
}
