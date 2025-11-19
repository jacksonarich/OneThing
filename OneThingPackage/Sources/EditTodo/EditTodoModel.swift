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
  var listID: TodoList.ID
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
    listID: TodoList.ID,
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
  
  public init(
    todo: Todo
  ) {
    self.todoID = todo.id
    self.listID = todo.listID
    self.title = todo.title
    self.notes = todo.notes
    self.deadline = todo.deadline
    var todoFrequency: Frequency? = nil
    if let unit = todo.frequencyUnit, let count = todo.frequencyCount {
      todoFrequency = .init(unit: unit, count: count)
    }
    let selection = FrequencySelection(todoFrequency)
    self.frequencySelection = selection
    var custom = Frequency(unit: .day)
    if let todoFrequency, selection == .custom {
      custom = todoFrequency
    }
    self.customFrequency = custom
  }
}


public extension EditTodoModel {

  func toggleDeadline(isOn: Bool) {
    if isOn {
      deadline = date.now
    } else {
      deadline = nil
    }
  }
  
  func editTodo() {
//    withErrorReporting {
//      try modelActions.editTodo(todo)
//    }
  }
}
