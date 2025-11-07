import SQLiteData
import SwiftUI

import AppDatabase
import AppModels
import Utilities


public struct SearchView: View {
  let model: SearchModel
  
  public init(model: SearchModel) {
    self.model = model
  }
  
  public var body: some View {
    ForEach(model.todos) { todo in
      TodoRowButton(
        todo: todo,
        subtitle: todo.deadline.map { "Due \($0.subtitle)" }
      ) {
        model.toggleComplete(todo.id, complete: todo.isTransitioning == false)
      }
      .listRowSeparator(.hidden)
    }
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  NavigationStack {
    List {
      SearchView(model: .init(text: "v"))
    }
  }
  .accentColor(.pink)
}
