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
  
  var listID: TodoList.ID
  var selectedList: TodoList? {
    selectableLists.first { $0.id == listID }
  }
  
  var title: String
  var notes: String
  var deadline: Date?
  
  var frequencySelection: FrequencySelection
  var customFrequency: Frequency
  var frequency: Frequency? {
    switch frequencySelection {
    case .never:
      return nil
    case .daily:
      return Frequency(unit: .day)
    case .weekly:
      return Frequency(unit: .week)
    case .monthly:
      return Frequency(unit: .month)
    case .yearly:
      return Frequency(unit: .year)
    case .custom:
      return customFrequency
    }
  }
  
  public init(
    listID: TodoList.ID,
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
      deadline = Calendar.current.date(
        byAdding: .day,
        value: 1,
        to: date.now
      )!
    } else {
      deadline = nil
    }
  }
  
  func createTodo() {
    let now = date.now
    let draft = Todo.Draft(
      listID: listID,
      title: title,
      notes: notes,
      deadline: deadline,
      frequencyUnit: frequency?.unit,
      frequencyCount: frequency?.count,
      createDate: now,
      modifyDate: now
    )
    withErrorReporting {
      try modelActions.createTodo(draft)
    }
  }
}
