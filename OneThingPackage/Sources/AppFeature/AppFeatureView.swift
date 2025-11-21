import AppDatabase
import AppModels
import CompletedDetail
import Dashboard
import DeletedDetail
import InProgressDetail
import ListDetail
import ScheduledDetail
import Sharing
import SQLiteData
import SwiftUI
import Utilities


public struct AppFeatureView: View {
  @State private var model: AppFeatureModel
  @Shared(.navPath) var navPath
  
  public init() {
    self.model = AppFeatureModel()
    let _ = prepareDependencies {
      $0.defaultDatabase = try! appDatabase()
    }
  }
  
  public var body: some View {
    NavigationStack(path: Binding($navPath)) {
      DashboardView()
        .navigationDestination(for: NavigationDestination.self) { dest in
          switch dest {
          case .listDetail(let listID):
            ListDetailView(listID: listID)
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
    .fontDesign(.rounded)
    .onFirstAppear(model.startRebalanceLoop)
  }
}



#Preview {
  AppFeatureView()
    .accentColor(.pink)
}
