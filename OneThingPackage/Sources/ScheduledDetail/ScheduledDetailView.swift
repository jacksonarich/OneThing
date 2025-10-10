import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


public struct ScheduledDetailView: View {
  @State var model: ScheduledDetailModel
  
  public init(model: ScheduledDetailModel) {
    self.model = model
  }
  
  public var body: some View {
    ZStack {
      List {
        ForEach(model.todos) { todo in
          TodoRowView(
            model: model,
            todo: todo
          )
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
      .listStyle(.plain)
      if model.stats?.isEmpty == true {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
      }
    }
    .navigationTitle("Scheduled")
    .navigationBarTitleDisplayMode(.large)
    .searchable(text: $model.searchText)
    .background(Color(.systemGroupedBackground))
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset().map {
        $0.modify(deadline: .now)
      }
    )
  }
  NavigationStack {
    ScheduledDetailView(model: .init())
  }
  .accentColor(.pink)
}
