import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


public struct ListDetailView: View {
  @State var model: ListDetailModel
  
  public init(model: ListDetailModel) {
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
      if model.stats?.isEmpty == true {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
      }
    }
    .navigationTitle(model.list?.name ?? "Unknown")
    .navigationBarTitleDisplayMode(.large)
    .background(Color(.systemGroupedBackground))
    .scrollContentBackground(.hidden)
    .searchable(text: $model.searchText)
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset().prefix(2).map {
        $0.modify(listID: 1)
      }
    )
  }
  NavigationStack {
    ListDetailView(model: .init(listID: 1))
  }
  .accentColor(.pink)
}
