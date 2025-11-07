// Exports `AppEntryPoint`, the root view of the entire app.
// Imports all other views as navigation destinations.


import Sharing
import SQLiteData
import SwiftUI

import AppDatabase
import AppModels
import CompletedDetail
import Dashboard
import DeletedDetail
import InProgressDetail
import ListDetail
import NewList
import AppModels
import ScheduledDetail
import Utilities


public struct AppEntryPoint: View {
  @Shared(.navPath) var navPath
  
  public init() {
    let _ = prepareDependencies {
      $0.defaultDatabase = try! appDatabase()
    }
  }
  
  public var body: some View {
    NavigationStack(path: Binding($navPath)) {
      DashboardView()
        .navigationDestination(for: NavigationDestination.self) { dest in
          switch dest {
          case .listDetail(let id):
            ListDetailView(model: .init(listID: id))
          case .computedListDetail(.completed):
            CompletedDetailView()
          case .computedListDetail(.deleted):
            DeletedDetailView()
          case .computedListDetail(.scheduled):
            ScheduledDetailView()
          case .computedListDetail(.inProgress):
            InProgressDetailView()
          default:
            EmptyView()
          }
        }
    }
  }
}



#Preview {
  AppEntryPoint()
    .accentColor(.pink)
}
