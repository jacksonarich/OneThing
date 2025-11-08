import SQLiteData


@Selection
public struct TodoListWithTodos: Codable, Equatable, Sendable {
  public var list: TodoList
  @Column(as: [Todo].JSONRepresentation.self)
  public var todos: [Todo]
  
  public init(
    list: TodoList,
    todos: [Todo]
  ) {
    self.list = list
    self.todos = todos
  }
}


extension TodoListWithTodos: Identifiable {
  public var id: Int { list.id }
}
