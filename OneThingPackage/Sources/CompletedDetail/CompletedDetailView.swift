import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


public struct CompletedDetailView: View {
  @State var model: CompletedDetailModel
  
  public init(model: CompletedDetailModel) {
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
      if model.todos.isEmpty {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
          .fontDesign(.rounded)
      }
    }
    .navigationTitle("Completed")
    .navigationBarTitleDisplayMode(.large)
    .background(Color(.systemGroupedBackground))
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset().map {
        $0.modify(completeDate: .now.addingTimeInterval(.random(in: -1000000 ... 0)))
      }
    )
  }
  NavigationStack {
    CompletedDetailView(model: .init())
  }
  .accentColor(.pink)
}
