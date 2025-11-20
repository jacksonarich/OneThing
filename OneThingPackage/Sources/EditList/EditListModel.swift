import AppModels
import Dependencies
import Foundation
import ModelActions
import SQLiteData
import SwiftUI


@MainActor
@Observable
public final class EditListModel {
  
  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions
  
  let listID: TodoList.ID
  var name: String
  var color: ListColor
  var showAlert: Bool
  
  public init(
    listID: TodoList.ID,
    name: String = "",
    color: ListColor = .red,
    alert: Bool = false
  ) {
    self.listID = listID
    self.name = name
    self.color = color
    self.showAlert = alert
  }
}


public extension EditListModel {
  
  func deleteList() {
    withErrorReporting {
      try modelActions.deleteList(listID)
    }
  }
  
  func showDialog() {
    showAlert = true
  }
  
  func fetch() {
    @Dependency(\.defaultDatabase) var database
    let result = withErrorReporting {
      try database.read { db in
        try TodoList
          .find(listID)
          .select { ($0.name, $0.color) }
          .fetchOne(db)
      }
    } ?? nil
    if let result {
      self.name = result.0
      self.color = result.1
    }
  }
  
  func editList() {
    withErrorReporting {
      try modelActions.editList(listID, name, color)
    }
  }
}
