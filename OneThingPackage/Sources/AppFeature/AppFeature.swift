// Exports `AppEntryPoint`, the root view of the entire app.
// Imports all other views as navigation destinations.


import Sharing
import SQLiteData
import SwiftUI

import AppDatabase
import Dashboard
import ListDetail
import Schema
import Utilities


public struct AppEntryPoint: View {
  @Shared(.navPath) var navPath
  
  public init() {
    let _ = prepareDependencies {
      $0.defaultDatabase = try! appDatabase(
        lists: .preset(),
        todos: .preset(),
        persist: false
      )
    }
  }
  
  public var body: some View {
    NavigationStack(path: Binding($navPath)) {
      DashboardView(model: .init())
        .navigationDestination(for: NavigationDestination.self) { dest in
          switch dest {
          case .dashboard: DashboardView(model: .init())
          case .todoList(let id): ListDetailView(model: .init(listID: id))
          case .computedList(let name): Text("Computed List")
          case .empty: EmptyView()
          }
        }
    }
  }
}



#Preview {
  AppEntryPoint()
}
