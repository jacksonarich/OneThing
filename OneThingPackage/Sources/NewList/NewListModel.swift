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
public final class NewListModel {
  
  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions
  
  @ObservationIgnored
  @FetchAll(
    TodoList
      .select(\.color)
      .distinct()
  )
  private var usedColors
  
  private var initialColor: ListColor {
    ListColor.all.first {
      !usedColors.contains($0)
    } ?? ListColor.all.randomElement()!
  }
  
  var name: String
  
  var color: ListColor = .red
  
  public init(
    name: String = "",
    color: ListColor? = nil
  ) {
    self.name = name
    self.color = color ?? initialColor
  }
}


public extension NewListModel {
  func createList() {
    let newList = TodoList.Draft(
      name: name.trimmed(),
      color: color,
      createDate: .now,
      modifyDate: .now
    )
    withErrorReporting {
      try modelActions.createList(newList)
    }
  }
}
