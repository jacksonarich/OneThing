// Utility functions relating to `Todo` and its variants.


import Dependencies
import Foundation
import SQLiteData
import StructuredQueries
import SwiftUI

import AppModels


public extension Todo.Draft {
  /// Creates a new `Todo.Draft` by describing changes to an existing one.
  func modify(
    id:                 Todo.ID??    = nil,
    title:              String?      = nil,
    notes:              String?      = nil,
    deadline:           Date??       = nil,
    frequencyUnitIndex: Int??        = nil,
    frequencyCount:     Int??        = nil,
    createDate:         Date?        = nil,
    modifyDate:         Date?        = nil,
    completeDate:       Date??       = nil,
    deleteDate:         Date??       = nil,
    rank:               Rank?        = nil,
    listID:             TodoList.ID? = nil
  ) -> Self {
    .init(
      id:                 id                 ?? self.id,
      title:              title              ?? self.title,
      notes:              notes              ?? self.notes,
      deadline:           deadline           ?? self.deadline,
      frequencyUnitIndex: frequencyUnitIndex ?? self.frequencyUnitIndex,
      frequencyCount:     frequencyCount     ?? self.frequencyCount,
      createDate:         createDate         ?? self.createDate,
      modifyDate:         modifyDate         ?? self.modifyDate,
      completeDate:       completeDate       ?? self.completeDate,
      deleteDate:         deleteDate         ?? self.deleteDate,
      rank:               rank               ?? self.rank,
      listID:             listID             ?? self.listID
    )
  }
}


public extension [Todo.Draft] {
  
  static func preset() -> [Todo.Draft] {
    func customTodo(
      title:              String = "",
      notes:              String = "",
      deadline:           Date?  = nil,
      frequencyUnitIndex: Int?   = nil,
      frequencyCount:     Int?   = nil
    ) -> Todo.Draft {
      Todo.Draft(
        id:                  nil,
        title:               title,
        notes:               notes,
        deadline:            deadline,
        frequencyUnitIndex:  frequencyUnitIndex,
        frequencyCount:      frequencyCount,
        createDate:          .now,
        modifyDate:          .now,
        completeDate:        nil,
        deleteDate:          nil,
        rank:                "0",
        listID:              .random(in: 1...21)
      )
    }
    let calendar = Calendar.current
    let customTodos = [
      customTodo(
        title: "Buy groceries",
        notes: "Milk, eggs, bread, coffee",
        deadline: calendar.date( // Tomorrow at 5:00 PM
          bySettingHour: 17,
          minute: 0,
          second: 0,
          of: calendar.date(
            byAdding: .day,
            value: 1, to: .now)!)!,
        frequencyUnitIndex: 1,
        frequencyCount: 1
      ),
      customTodo(
        title: "Call mom",
        deadline: calendar.date( // Sunday at 3:00 PM
          bySettingHour: 15,
          minute: 0,
          second: 0,
          of: calendar.nextDate(
            after: .now,
            matching: DateComponents(weekday: 1),
            matchingPolicy: .nextTime)!)
      ),
      customTodo(
        title: "Finish quarterly report",
        notes: "Double-check revenue figures",
        deadline: calendar.date( // End of this month
          bySettingHour: 17,
          minute: 0,
          second: 0,
          of: calendar.date(
            byAdding: .month,
            value: 1,
            to: calendar.date(from: calendar.dateComponents([.year, .month], from: .now))!)!)!,
        frequencyUnitIndex: 2,
        frequencyCount: 3
      ),
      customTodo(
        title: "Walk the dog",
        deadline: calendar.date( // Today at 6:30 PM
          bySettingHour: 18,
          minute: 30,
          second: 0,
          of: .now)!
      ),
      customTodo(
        title: "Plan weekend trip",
        notes: "Research hiking trails"
      ),
      customTodo(
        title: "Water the plants",
        notes: "Especially the fern in the living room",
      ),
      customTodo(
        title: "Clean the garage",
        deadline: calendar.date( // Next Saturday at 10:00 AM
          bySettingHour: 10,
          minute: 0,
          second: 0,
          of: calendar.nextDate(
            after: .now,
            matching: DateComponents(weekday: 7),
            matchingPolicy: .nextTime)!)
      ),
      customTodo(
        title: "Renew car registration",
        notes: "Bring insurance card",
        deadline: calendar.date( // Two weeks from today
          byAdding: .day,
          value: 14,
          to: .now)!,
        frequencyUnitIndex: 3,
        frequencyCount: 1
      ),
      customTodo(
        title: "Read 'Atomic Habits'"
      ),
      customTodo(
        title: "Backup laptop",
        notes: "Use external SSD",
        deadline: calendar.date( // Friday at 8:00 PM
          bySettingHour: 20,
          minute: 0,
          second: 0,
          of: calendar.nextDate(
            after: .now,
            matching: DateComponents(weekday: 6),
            matchingPolicy: .nextTime)!)!
      ),
      customTodo(
        title: "Reply to Sarah's email",
        notes: "About the project update"),
      customTodo(
        title: "Pay electricity bill",
        deadline: calendar.nextDate( // Next Monday
          after: .now,
          matching: DateComponents(weekday: 2),
          matchingPolicy: .nextTime)!
      ),
      customTodo(
        title: "Make dentist appointment",
        notes: "Prefer morning slot"
      ),
      customTodo(
        title: "Order printer ink"
      ),
      customTodo(
        title: "Meal prep for the week",
        notes: "Try the new pasta salad recipe",
        deadline: calendar.date( // Sunday afternoon
          bySettingHour: 14,
          minute: 0,
          second: 0,
          of: calendar.nextDate(
            after: .now,
            matching: DateComponents(weekday: 1),
            matchingPolicy: .nextTime)!)!,
        frequencyUnitIndex: 1,
        frequencyCount: 1
      ),
      customTodo(
        title: "Run 5k",
        notes: "Track time in Strava"
      ),
      customTodo(
        title: "Organize photo library",
        notes: "Sort into yearly folders"
      ),
      customTodo(
        title: "Vacuum living room"
      ),
      customTodo(
        title: "Learn SwiftUI animations",
        notes: "Start with matchedGeometryEffect"
      ),
      customTodo(
        title: "Update résumé",
        notes: "Add iOS projects",
        deadline: calendar.date( // Next Friday at 4:00 PM
          bySettingHour: 16,
          minute: 0,
          second: 0,
          of: calendar.nextDate(
            after: .now,
            matching: DateComponents(weekday: 6),
            matchingPolicy: .nextTime)!)!
      ),
      customTodo(
        title: .loremIpsum,
        notes: .loremIpsum
      )
    ]
      .shuffled()
    @Dependency(\.rankGeneration) var rankGeneration
    let ranks = rankGeneration.distribute(customTodos.count)
    return zip(customTodos, ranks).map { todo, rank in
      todo.modify(rank: rank)
    }
  }
}


public extension Todo {
  /// True iff `title` contains the given text, case insensitive.
  func search(_ text: String) -> some QueryExpression<Bool> {
    text.isEmpty
    || title.lowercased().contains(text.lowercased())
  }
}
public extension Todo.Draft {
  /// True iff `title` contains the given text, case insensitive.
  func search(_ text: String) -> Bool {
    text.isEmpty
    || title.lowercased().contains(text.lowercased())
  }
}
public extension Todo.TableColumns {
  /// True iff `title` contains the given text, case insensitive.
  func search(_ text: String) -> some QueryExpression<Bool> {
    text.isEmpty
    || title.lower().contains(text.lowercased())
  }
}


public extension Todo.TableColumns {
  func contains(_ text: String) -> some QueryExpression<Bool> {
    title.lower().contains(text.lowercased())
  }
  var isCompleted: some QueryExpression<Bool> {
    completeDate != nil
  }
  var isDeleted: some QueryExpression<Bool> {
    deleteDate != nil
  }
  var isInProgress: some QueryExpression<Bool> {
    completeDate == nil && deleteDate == nil
  }
  var isScheduled: some QueryExpression<Bool> {
    isInProgress && deadline != nil
  }
}
