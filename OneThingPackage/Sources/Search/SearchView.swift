import AppDatabase
import AppModels
import SQLiteData
import SwiftUI
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
        subtitle: todo.deadline.map { "Due \($0.relativeString)" }
      ) {
        model.todoRowTapped(todo.id, shouldTransition: todo.transition == nil)
      }
      .listRowSeparator(.hidden)
    }
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  let model = SearchModel(text: "v")
  NavigationStack {
    List {
      SearchView(model: model)
    }
  }
  .accentColor(.pink)
}
