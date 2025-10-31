import Foundation
import SQLiteData

@Table
public struct Todo: Codable, Equatable, Identifiable, Sendable {
  public let id:                 ID
  public var title:              String = ""
  public var notes:              String = ""
  public var deadline:           Date? = nil
  public var frequencyUnitIndex: Int? = nil
  public var frequencyCount:     Int? = nil
  public var createDate:         Date
  public var modifyDate:         Date
  public var completeDate:       Date? = nil
  public var deleteDate:         Date? = nil
  public var rank:               Rank
  public var listID:             TodoList.ID
  public var isTransitioning:    Bool = false
  
  public typealias ID = Int
  
  public init(
    id:                 ID,
    title:              String = "",
    notes:              String = "",
    deadline:           Date? = nil,
    frequencyUnitIndex: Int? = nil,
    frequencyCount:     Int? = nil,
    createDate:         Date,
    modifyDate:         Date,
    completeDate:       Date? = nil,
    deleteDate:         Date? = nil,
    rank:               Rank,
    listID:             TodoList.ID,
    isTransitioning:    Bool = false
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
    self.rank               = rank
    self.listID             = listID
    self.isTransitioning    = isTransitioning
  }
}

extension Todo.Draft: Equatable, Sendable {}

extension Todo.Draft {
  public init(
    id:                 Todo.ID?    = nil,
    title:              String      = "",
    notes:              String      = "",
    deadline:           Date?       = nil,
    frequencyUnitIndex: Int?        = nil,
    frequencyCount:     Int?        = nil,
    createDate:         Date?       = nil,
    modifyDate:         Date?       = nil,
    completeDate:       Date?       = nil,
    deleteDate:         Date?       = nil,
    rank:               Rank,
    listID:             TodoList.ID
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
      id:                 id,
      title:              title,
      notes:              notes,
      deadline:           deadline,
      frequencyUnitIndex: frequencyUnitIndex,
      frequencyCount:     frequencyCount,
      createDate:         created,
      modifyDate:         modified,
      completeDate:       completeDate,
      deleteDate:         deleteDate,
      rank:               rank,
      listID:             listID
    )
  }
}
