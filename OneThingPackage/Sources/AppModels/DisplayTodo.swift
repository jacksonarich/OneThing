import Foundation
import StructuredQueries

@Selection
public struct DisplayTodo: Codable, Equatable, Identifiable, Sendable {
  public let id: Todo.ID
  public let listID: TodoList.ID
  public var completeDate: Date?
  public var deadline: Date?
  public var deleteDate: Date?
  public var title: String
  public var isTransitioning: Bool
  
  public init(
    id: Todo.ID,
    listID: TodoList.ID,
    completeDate: Date? = nil,
    deadline: Date? = nil,
    deleteDate: Date? = nil,
    title: String,
    isTransitioning: Bool
  ) {
    self.id = id
    self.listID = listID
    self.completeDate = completeDate
    self.deadline = deadline
    self.deleteDate = deleteDate
    self.title = title
    self.isTransitioning = isTransitioning
  }
}
