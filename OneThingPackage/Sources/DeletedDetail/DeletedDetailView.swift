import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


public struct DeletedDetailView: View {
  @State var model: DeletedDetailModel
  
  public init(model: DeletedDetailModel) {
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
    .navigationTitle("Deleted")
    .navigationBarTitleDisplayMode(.large)
    .background(Color(.systemGroupedBackground))
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset().map {
        $0.modify(deleteDate: .now.addingTimeInterval(.random(in: -1000000 ... 0)))
      }
    )
  }
  NavigationStack {
    DeletedDetailView(model: .init())
  }
  .accentColor(.pink)
}
