import AppModels
import Foundation
@testable import ModelActions
import Testing
import TestSupport


struct TodoTests {
  
  @Test
  func createRanks() async throws {
    await prepareTest {
      TodoListData {
        TodoData(rank: "A")
        TodoData(rank: "A0")
        TodoData(rank: "B")
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.rerankTodos([3], 2)
      } assert: {
        $0.todos[0].rank = "0"
        $0.todos[1].rank = "1"
        $0.todos[2].rank = "00"
      }
    }
  }
  
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
  func completeTodoWithFrequency() async throws {
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
  func editTodo() async throws {
    await prepareTest {
      TodoListData {
        TodoData()
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.editTodo(1, 1, "Title", "Notes", Date(2), Frequency(unit: .year, count: 5))
      } assert: {
        $0.todos[0] = .init(
          1,
          listID: 1,
          title: "Title",
          notes: "Notes",
          deadline: Date(2),
          frequencyUnit: .year,
          frequencyCount: 5,
          createDate: Date(0),
          modifyDate: Date(0)
        )
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
  func purge() async throws {
    await prepareTest {
      TodoListData {
        TodoData()
        TodoData(deleteDate: .distantPast)
      }
    } dependencies: {
      $0.calendar = .current
    }test: {
      let model = ModelActions.testValue
      await runAction {
        try model.purge()
      } assert: {
        $0.todos.remove(at: 1)
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
  func rebalanceTodoRanks() async throws {
    await prepareTest {
      TodoListData {
        TodoData(rank: "1")
        TodoData(rank: "9999999999")
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.rebalanceTodoRanks()
      } assert: {
        $0.todos[0].rank = "0"
        $0.todos[1].rank = "1"
      }
    }
  }
  
  @Test
  func rerankTodos() async throws {
    await prepareTest {
      TodoListData {
        TodoData()
        TodoData()
        TodoData()
        TodoData()
      }
    } test: {
      let model = ModelActions.testValue
      await runAction {
        try model.rerankTodos([1, 2], nil)
      } assert: {
        $0.todos[0].rank = "30"
        $0.todos[1].rank = "31"
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
}
