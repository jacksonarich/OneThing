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
      .select(\.colorIndex)
      .distinct()
      .order(by: \.colorIndex)
  )
  private var usedColorIndexes
  
  private var allColorIndexes = 0...9
  
  private var initialColorIndex: Int {
    allColorIndexes.first {
      !usedColorIndexes.contains($0)
    } ?? allColorIndexes.randomElement()!
  }
  
  var name: String
  
  var colorIndex: Int = 0
  
  public init(
    name:       String = "",
    colorIndex: Int?   = nil
  ) {
    self.name       = name
    self.colorIndex = colorIndex ?? initialColorIndex
  }
}


public extension NewListModel {
  func createList() {
    let newList = TodoList.Draft(
      name: name.trimmed(),
      colorIndex: colorIndex,
      createDate: .now,
      modifyDate: .now
    )
    withErrorReporting {
      try modelActions.createList(newList)
    }
  }
}
