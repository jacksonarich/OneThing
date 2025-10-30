import Foundation
import SQLiteData

@Table
public struct TodoList: Codable, Identifiable, Equatable, Sendable {
  public let id:         ID
  public var name:       String = ""
  public var colorIndex: Int = 0
  public var createDate: Date
  public var modifyDate: Date
  
  public typealias ID = Int
  
  public init(
    id:         ID,
    name:       String = "",
    colorIndex: Int = 0,
    createDate: Date,
    modifyDate: Date
  ) {
    self.id         = id
    self.name       = name
    self.colorIndex = colorIndex
    self.createDate = createDate
    self.modifyDate = modifyDate
  }
}


extension TodoList.Draft: Equatable, Sendable {}

extension TodoList.Draft {
  public init(
    id:         TodoList.ID? = nil,
    name:       String = "",
    colorIndex: Int = 0,
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
      colorIndex: colorIndex,
      createDate: created,
      modifyDate: modified
    )
  }
}
