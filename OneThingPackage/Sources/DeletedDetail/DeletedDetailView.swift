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
      }
      .listStyle(.plain)
      if model.stats?.isEmpty == true {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
      }
    }
    .navigationTitle("Deleted")
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
        $0.modify(deleteDate: .now)
      }
    )
  }
  NavigationStack {
    DeletedDetailView(model: .init())
  }
  .accentColor(.pink)
}
