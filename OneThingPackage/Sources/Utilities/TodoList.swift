// Utility functions relating to `TodoList` and its variants.


import Dependencies
import Foundation
import SQLiteData
import SwiftUI

import Schema


public extension TodoList.Draft {
  
  /// Shortcut initializer for use in testing.
  static func preset(
    id:         TodoList.ID? = nil,
    name:       String       = "",
    colorIndex: Int          = 0,
    createDate: Date?        = nil,
    modifyDate: Date?        = nil
  ) -> Self {
    let cd = createDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    let md = modifyDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    return .init(
      id:         id,
      name:       name,
      colorIndex: colorIndex,
      createDate: cd,
      modifyDate: md
    )
  }
  
  /// Creates a new `TodoList.Draft` by describing changes to an existing one.
  func modify(
    id:         TodoList.ID?? = nil,
    name:       String?       = nil,
    colorIndex: Int?          = nil,
    createDate: Date??        = nil,
    modifyDate: Date??        = nil
  ) -> Self {
    let cd = createDate.flatMap { $0 ?? {
      @Dependency(\.date) var date
      return date.now
    }() }
    let md = modifyDate.flatMap { $0 ?? {
      @Dependency(\.date) var date
      return date.now
    }() }
    return .init(
      id:         id         ?? self.id,
      name:       name       ?? self.name,
      colorIndex: colorIndex ?? self.colorIndex,
      createDate: cd         ?? self.createDate,
      modifyDate: md         ?? self.modifyDate
    )
  }
}


public extension [TodoList.Draft] {
  
  static func preset(
    modify: @escaping (TodoList.Draft) -> TodoList.Draft = { $0 }
  ) -> Self {
    let names: [String] = ["Daily Grind", "Weekend Projects", "Errand Run", "Home Repairs", "Study Sessions", "Career Goals", "Gift Shopping", "Moving Day Prep", "Fitness", "Meal Prep", "Party Planning", "Travel", "Finance", "Pet Care", "Morning Routine", "Declutter", "Learning Skills", "Health & Wellness", "Garden Chores", "Big Ideas", .loremIpsum]
    return names.map {
      TodoList.Draft.preset(
        name: $0,
        colorIndex: Color.all.indices.randomElement()!
      )
    }
    .shuffled()
    .map(modify)
  }
}
