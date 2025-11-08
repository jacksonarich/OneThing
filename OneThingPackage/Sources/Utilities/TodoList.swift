import AppModels
import Dependencies
import Foundation
import SQLiteData
import SwiftUI


public extension TodoList.Draft {
  
  func modified(_ body: (inout TodoList.Draft) -> Void) -> TodoList.Draft {
    var copy = self
    body(&copy)
    return copy
  }
}
