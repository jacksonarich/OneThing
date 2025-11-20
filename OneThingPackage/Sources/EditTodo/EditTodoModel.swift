import AppModels
import Dependencies
import Foundation
import ModelActions
import SQLiteData
import SwiftUI
import Utilities


@MainActor
@Observable
public final class EditTodoModel {
  
  @ObservationIgnored
  @Dependency(\.date)
  private var date
  
  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions
  
  @ObservationIgnored
  @FetchAll(
    TodoList
      .order(by: \.name)
  )
  var selectableLists
  
  let todoID: Todo.ID
  var listID: TodoList.ID?
  var title: String
  var notes: String
  var deadline: Date?
  var frequencySelection: FrequencySelection
  var customFrequency: Frequency
  var actualFrequency: Frequency? {
    Frequency(
      selection: frequencySelection,
      custom: customFrequency
    )
  }
  
  public init(
    todoID: Todo.ID,
    listID: TodoList.ID? = nil,
    title: String = "",
    notes: String = "",
    deadline: Date? = nil,
    frequencySelection: FrequencySelection = .never,
    customFrequency: Frequency = Frequency(unit: .day)
  ) {
    self.todoID = todoID
    self.listID = listID
    self.title = title
    self.notes = notes
    self.deadline = deadline
    self.frequencySelection = frequencySelection
    self.customFrequency = customFrequency
  }
}


public extension EditTodoModel {
  
  func fetch() {
    @Dependency(\.defaultDatabase) var database
    let result = withErrorReporting {
      try database.read { db in
        try Todo
          .find(todoID)
          .select { ($0.listID, $0.title, $0.notes, $0.deadline, $0.frequencyUnit, $0.frequencyCount) }
          .fetchOne(db)
      }
    } ?? nil
    if let result {
      self.listID = result.0
      self.title = result.1
      self.notes = result.2
      self.deadline = result.3
      var frequency: Frequency? = nil
      if let unit = result.4, let count = result.5 {
        frequency = .init(unit: unit, count: count)
      }
      let selection = FrequencySelection(frequency)
      self.frequencySelection = selection
      if let frequency, selection == .custom {
        self.customFrequency = frequency
      }
    }
  }

  func toggleDeadline(isOn: Bool) {
    if isOn {
      deadline = date.now
    } else {
      deadline = nil
    }
  }
  
  func editTodo() {
    guard let listID else { return }
    withErrorReporting {
      try modelActions.editTodo(todoID, listID, title, notes, deadline, actualFrequency)
    }
  }
}
