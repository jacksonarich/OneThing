// Utility functions relating to `TodoList` and its variants.


import Dependencies
import Foundation
import SQLiteData
import SwiftUI

import AppModels


public extension TodoList.Draft {
  
  func modified(_ body: (inout TodoList.Draft) -> Void) -> TodoList.Draft {
    var copy = self
    body(&copy)
    return copy
  }
}
