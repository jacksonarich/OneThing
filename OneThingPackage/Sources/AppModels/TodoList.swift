import Foundation
import SQLiteData

@Table
public struct TodoList: Codable, Identifiable, Equatable, Sendable {
  public let id:         ID
  public let name:       String
  public let colorIndex: Int
  public let createDate: Date
  public let modifyDate: Date
  
  public typealias ID = Int
  
  public init(
    id:         ID,
    name:       String,
    colorIndex: Int,
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
