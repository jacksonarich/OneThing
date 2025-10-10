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
      }
      .listStyle(.plain)
      if model.stats?.isEmpty == true {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
      }
    }
    .navigationTitle("Completed")
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
        $0.modify(completeDate: .now)
      }
    )
  }
  NavigationStack {
    CompletedDetailView(model: .init())
  }
  .accentColor(.pink)
}
