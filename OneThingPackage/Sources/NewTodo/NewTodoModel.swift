import Dependencies
import Foundation
import SQLiteData
import StructuredQueriesCore
import SwiftUI

import ModelActions
import AppModels
import Utilities


@MainActor
@Observable
public final class NewTodoModel {
  
  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions
  
  @ObservationIgnored
  @FetchAll(
    TodoList
      .all
  )
  var selectableLists
  
  var title: String
  var notes: String
  var deadline: Date?
  
  var listID: TodoList.ID
  var listName: String
  var listColorIndex: Int
  
  public init(
    title: String = "",
    notes: String = "",
    deadline: Date? = nil,
    list: TodoList
  ) {
    self.title = title
    self.notes = notes
    self.deadline = deadline
    self.listID = list.id
    self.listName = list.name
    self.listColorIndex = list.colorIndex
  }
  
  public init(
    title: String = "",
    notes: String = "",
    deadline: Date? = nil,
    listID: TodoList.ID,
    listName: String,
    listColorIndex: Int
  ) {
    self.title = title
    self.notes = notes
    self.deadline = deadline
    self.listID = listID
    self.listName = listName
    self.listColorIndex = listColorIndex
  }
}


public extension NewTodoModel {
  func toggleDeadline(isOn: Bool) {
    if isOn {
      @Dependency(\.date) var date
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
    
  }
}
