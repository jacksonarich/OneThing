import AppModels
import Dependencies
import Foundation
import ModelActions
import SQLiteData
import SwiftUI
import Utilities


@MainActor
@Observable
public final class NewTodoModel {
  
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
    listID: TodoList.ID? = nil,
    title: String = "",
    notes: String = "",
    deadline: Date? = nil,
    frequencySelection: FrequencySelection = .never,
    customFrequency: Frequency = Frequency(unit: .day)
  ) {
    self.listID = listID
    self.title = title
    self.notes = notes
    self.deadline = deadline
    self.frequencySelection = frequencySelection
    self.customFrequency = customFrequency
  }
}


public extension NewTodoModel {

  func toggleDeadline(isOn: Bool) {
    if isOn {
      deadline = date.now
    } else {
      deadline = nil
    }
  }
  
  func createTodo() {
    guard let listID else { return }
    let now = date.now
    let draft = Todo.Draft(
      listID: listID,
      title: title,
      notes: notes,
      deadline: deadline,
      frequencyUnit: actualFrequency?.unit,
      frequencyCount: actualFrequency?.count,
      createDate: now,
      modifyDate: now
    )
    withErrorReporting {
      try modelActions.createTodo(draft)
    }
  }
}
