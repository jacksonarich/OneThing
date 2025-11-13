import Foundation
import SQLiteData


@Table
public struct Todo: Codable, Equatable, Identifiable, Sendable {
  public let id: ID
  public var listID: TodoList.ID
  public var rank: Rank
  public var title: String = ""
  public var notes: String = ""
  public var deadline: Date? = nil
  public var frequencyUnit: FrequencyUnit? = nil
  public var frequencyCount: Int? = nil
  public var createDate: Date
  public var modifyDate: Date
  public var completeDate: Date? = nil
  public var deleteDate: Date? = nil
  public var transition: TransitionAction? = nil
  
  public typealias ID = Int
  
  public init(
    id: ID,
    listID: TodoList.ID,
    rank: Rank,
    title: String = "",
    notes: String = "",
    deadline: Date? = nil,
    frequencyUnit: FrequencyUnit? = nil,
    frequencyCount: Int? = nil,
    createDate: Date,
    modifyDate: Date,
    completeDate: Date? = nil,
    deleteDate: Date? = nil,
    transition: TransitionAction? = nil
  ) {
    self.id = id
    self.listID = listID
    self.rank = rank
    self.title = title
    self.notes = notes
    self.deadline = deadline
    self.frequencyUnit = frequencyUnit
    self.frequencyCount = frequencyCount
    self.createDate = createDate
    self.modifyDate = modifyDate
    self.completeDate = completeDate
    self.deleteDate = deleteDate
    self.transition = transition
  }
}


extension Todo.Draft: Equatable, Sendable {}


extension Todo.Draft {
  public init(
    _ id: Todo.ID? = nil,
    listID: TodoList.ID,
    rank: Rank,
    title: String = "",
    notes: String = "",
    deadline: Date? = nil,
    frequencyUnit: FrequencyUnit? = nil,
    frequencyCount: Int? = nil,
    createDate: Date? = nil,
    modifyDate: Date? = nil,
    completeDate: Date? = nil,
    deleteDate: Date? = nil,
    transition: TransitionAction? = nil
  ) {
    self.init(
      id: id,
      listID: listID,
      rank: rank,
      title: title,
      notes: notes,
      deadline: deadline,
      frequencyUnit: frequencyUnit,
      frequencyCount: frequencyCount,
      createDate: createDate ?? {
        @Dependency(\.date) var date
        return date.now
      }(),
      modifyDate: modifyDate ?? createDate ?? {
        @Dependency(\.date) var date
        return date.now
      }(),
      completeDate: completeDate,
      deleteDate: deleteDate,
      transition: transition
    )
  }
}
