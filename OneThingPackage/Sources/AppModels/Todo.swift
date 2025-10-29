import Foundation
import SQLiteData

@Table
public struct Todo: Codable, Equatable, Identifiable, Sendable {
  public let id:                 ID
  public let title:              String
  public let notes:              String
  public let deadline:           Date?
  public let frequencyUnitIndex: Int?
  public let frequencyCount:     Int?
  public let createDate:         Date
  public let modifyDate:         Date
  public var completeDate:       Date?
  public let deleteDate:         Date?
  public let order:              String
  public let listID:             TodoList.ID
  
  public typealias ID = Int
  
  public init(
    id:                 ID,
    title:              String,
    notes:              String,
    deadline:           Date?,
    frequencyUnitIndex: Int?,
    frequencyCount:     Int?,
    createDate:         Date,
    modifyDate:         Date,
    completeDate:       Date?,
    deleteDate:         Date?,
    order:              String,
    listID:             TodoList.ID
  ) {
    self.id                 = id
    self.title              = title
    self.notes              = notes
    self.deadline           = deadline
    self.frequencyUnitIndex = frequencyUnitIndex
    self.frequencyCount     = frequencyCount
    self.createDate         = createDate
    self.modifyDate         = modifyDate
    self.completeDate       = completeDate
    self.deleteDate         = deleteDate
    self.order              = order
    self.listID             = listID
  }
}

extension Todo.Draft: Equatable, Sendable {}
