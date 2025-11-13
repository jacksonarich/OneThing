import AppModels
import Dependencies
import Foundation


extension Todo {
  @_disfavoredOverload
  public init(
    _ id: ID,
    listID: TodoList.ID,
    rank: Rank = "0", // must specify for multiple todos in a list
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
