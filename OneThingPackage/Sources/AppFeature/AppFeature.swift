// Exports `AppEntryPoint`, the root view of the entire app.
// Imports all other views as navigation destinations.


import Sharing
import SQLiteData
import SwiftUI

import AppDatabase
import Dashboard
import Schema


public struct AppEntryPoint: View {
  @Shared(.navPath) var navPath
  
  public var body: some View {
    NavigationStack(path: Binding($navPath)) {
      DashboardView(model: .init())
        .navigationDestination(for: NavigationDestination.self) { dest in
          switch dest {
          case .dashboard: DashboardView(model: .init())
          case .todoList(let id): Text("Todo List")
          case .computedList(let name): Text("Computed List")
          case .empty: EmptyView()
          }
        }
    }
  }
}



#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset()
    )
  }
  AppEntryPoint()
}
