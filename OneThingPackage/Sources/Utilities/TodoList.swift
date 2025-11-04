// Utility functions relating to `TodoList` and its variants.


import Dependencies
import Foundation
import SQLiteData
import SwiftUI

import AppModels


public extension TodoList.Draft {
  
  /// Shortcut initializer for use in testing.
  static func preset(
    id:         TodoList.ID? = nil,
    name:       String       = "",
    color: ListColor          = .red,
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
      color: color,
      createDate: cd,
      modifyDate: md
    )
  }
  
  func modified(_ body: (inout TodoList.Draft) -> Void) -> TodoList.Draft {
    var copy = self
    body(&copy)
    return copy
  }
}


public extension [TodoList.Draft] {
  
  static func preset() -> Self {
    let names: [String] = ["Daily Grind", "Weekend Projects", "Errand Run", "Home Repairs", "Study Sessions", "Career Goals", "Gift Shopping", "Moving Day Prep", "Fitness", "Meal Prep", "Party Planning", "Travel", "Finance", "Pet Care", "Morning Routine", "Declutter", "Learning Skills", "Health & Wellness", "Garden Chores", "Big Ideas", .loremIpsum]
    return names.map {
      TodoList.Draft.preset(
        name: $0,
        color: ListColor.all.randomElement()!
      )
    }
    .shuffled()
  }
}
