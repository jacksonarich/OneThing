//import BaseTestSuite
//import Schema
//import SQLiteData
//import Testing
//
//@testable import ModelActions
//
//
//extension BaseTestSuite {
//  struct ModelActionsTests {
//    
//    @Test
//    func createList() async throws {
//      @FetchAll(TodoList.all) var allLists
//      #expect(allLists.count == 0)
//      let l1 = TodoList.preset()
//      try ModelActions.liveValue.createList(l1)
//      try await $allLists.load()
//      #expect(allLists.count == 1)
//    }
//    
//    @Test
//    func deleteList() async throws {
//      @FetchAll(TodoList.all) var allLists
//      let l1 = TodoList.preset()
//      try ModelActions.liveValue.createList(l1)
//      try ModelActions.liveValue.deleteList(1)
//      try await $allLists.load()
//      #expect(allLists.count == 0)
//    }
//    
//    @Test
//    func updateList() async throws {
//      @FetchAll(TodoList.all) var allLists
//      let l1 = TodoList.preset()
//      try ModelActions.liveValue.createList(l1)
//      try ModelActions.liveValue.updateList(1, "Grocery", 5)
//      try await $allLists.load()
//      #expect(allLists.count == 1)
//      #expect(allLists[0].name == "Grocery")
//      #expect(allLists[0].colorIndex == 5)
//    }
//    
//    @Test
//    func createTodo() async throws {
//      @FetchAll(Todo.all) var allTodos
//      let l1 = TodoList.preset()
//      let t1 = Todo.preset()
//      try ModelActions.liveValue.createList(l1)
//      try ModelActions.liveValue.createTodo(t1)
//      try await $allTodos.load()
//      #expect(allTodos.count == 1)
//    }
//    
//    @Test
//    func eraseTodo() async throws {
//      @FetchAll(Todo.all) var allTodos
//      let l1 = TodoList.preset()
//      let t1 = Todo.preset()
//      try ModelActions.liveValue.createList(l1)
//      try ModelActions.liveValue.createTodo(t1)
//      try ModelActions.liveValue.eraseTodo(1)
//      try await $allTodos.load()
//      #expect(allTodos.count == 0)
//    }
//    
//    @Test
//    func createTodo() async throws {
//      @FetchAll(Todo.all) var allTodos
//      let l1 = TodoList.preset()
//      let t1 = Todo.preset()
//      try ModelActions.liveValue.createList(l1)
//      try ModelActions.liveValue.createTodo(t1)
//      try ModelActions.liveValue.completeTodo(1)
//      try await $allTodos.load()
//      #expect(allTodos.count == 1)
//      #expect(allTodos[0].completeDate)
//    }
//  }
//}
