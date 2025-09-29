// Utility functions relating to `TodoList` and its variants.

import Dependencies
import Foundation
import SQLiteData
import SwiftUI

import Schema


public extension TodoList.Draft {
  /// Shortcut initializer for use in testing.
  static func preset(
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


public extension [TodoList.Draft] {
  static func preset(
    colorIndex: () -> Int = { Color.all.indices.randomElement()! }
  ) -> Self {
    let names: [String] = ["Daily Grind", "Weekend Projects", "Errand Run", "Home Repairs", "Study Sessions", "Career Goals", "Gift Shopping", "Moving Day Prep", "Fitness", "Meal Prep", "Party Planning", "Travel", "Finance", "Pet Care", "Morning Routine", "Declutter", "Learning Skills", "Health & Wellness", "Garden Chores", "Big Ideas", .loremIpsum]
    return names.shuffled().map {
      TodoList.Draft.preset(
        name: $0,
        colorIndex: colorIndex()
      )
    }
  }
}
