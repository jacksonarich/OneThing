import Dependencies
import Schema
import SwiftUI


extension Todo.Draft {
  /// Shortcut initializer for use in testing.
  public static func preset(
    id: Todo.ID? = nil,
    title: String = "",
    notes: String = "",
    deadline: Date? = nil,
    frequencyUnitIndex: Int? = nil,
    frequencyCount: Int? = nil,
    createDate: Date? = nil,
    modifyDate: Date? = nil,
    completeDate: Date? = nil,
    deleteDate: Date? = nil,
    order: String,
    listID: TodoList.ID
  ) -> Self {
    let created = createDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    let modified = modifyDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    return .init(
      id: id,
      title: title,
      notes: notes,
      deadline: deadline,
      frequencyUnitIndex: frequencyUnitIndex,
      frequencyCount: frequencyCount,
      createDate: created,
      modifyDate: modified,
      completeDate: completeDate,
      deleteDate: deleteDate,
      order: order,
      listID: listID
    )
  }
}


extension TodoList.Draft {
  /// Shortcut initializer for use in testing.
  public static func preset(
    id: TodoList.ID? = nil,
    name: String = "",
    colorIndex: Int = 0,
    createDate: Date? = nil,
    modifyDate: Date? = nil
  ) -> Self {
    let created = createDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    let modified = modifyDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    return .init(
      id: id,
      name: name,
      colorIndex: colorIndex,
      createDate: created,
      modifyDate: modified
    )
  }
}
