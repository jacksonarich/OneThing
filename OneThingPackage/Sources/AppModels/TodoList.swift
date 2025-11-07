import Foundation
import SQLiteData

@Table
public struct TodoList: Codable, Identifiable, Equatable, Sendable {
  public let id: ID
  public var name: String = ""
  public var color: ListColor = .red
  public var createDate: Date
  public var modifyDate: Date
  
  public typealias ID = Int
  
  public init(
    id: ID,
    name: String = "",
    color: ListColor = .red,
    createDate: Date,
    modifyDate: Date
  ) {
    self.id = id
    self.name = name
    self.color = color
    self.createDate = createDate
    self.modifyDate = modifyDate
  }
}


extension TodoList.Draft: Equatable, Sendable {}

extension TodoList.Draft {
  public init(
    id: TodoList.ID? = nil,
    name: String = "",
    color: ListColor = .red,
    createDate: Date? = nil,
    modifyDate: Date? = nil
  ) {
    let created = createDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    let modified = modifyDate ?? createDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    self.init(
      id: id,
      name: name,
      color: color,
      createDate: created,
      modifyDate: modified
    )
  }
}
