import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


public struct InProgressDetailView: View {
  @State var model: InProgressDetailModel
  
  public init(model: InProgressDetailModel) {
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
    .navigationTitle("In Progress")
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
        $0.modify(listID: 1)
      }
    )
  }
  NavigationStack {
    InProgressDetailView(model: .init())
  }
  .accentColor(.pink)
}
