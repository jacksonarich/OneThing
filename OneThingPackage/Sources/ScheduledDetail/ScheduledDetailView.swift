import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


public struct ScheduledDetailView: View {
  @State private var model = ScheduledDetailModel()
  
  public init() {}
  
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
      if model.todos.isEmpty {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
          .fontDesign(.rounded)
      }
    }
    .navigationTitle("Scheduled")
    .navigationBarTitleDisplayMode(.large)
    .background(Color(.systemGroupedBackground))
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset()
    )
  }
  NavigationStack {
    ScheduledDetailView()
  }
  .accentColor(.pink)
}
