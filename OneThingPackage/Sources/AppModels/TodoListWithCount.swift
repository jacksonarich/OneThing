import SQLiteData

@Selection
public struct TodoListWithCount: Codable, Equatable, Identifiable, Sendable {
  public var list: TodoList
  public var count: Int
  public var id: Int { list.id }
}
