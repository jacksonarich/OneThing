import AppDatabase
import SQLiteData
import SwiftUI
import Utilities


public struct DeletedDetailView: View {
  @State private var model = DeletedDetailModel()
  
  public init() {}
  
  public var body: some View {
    ZStack {
      List {
        ForEach(model.todos) { todo in
          TodoRowButton(
            todo: todo,
            subtitle: todo.deleteDate.map { "Deleted \($0.subtitle)" }
          ) {
            model.putBackTodo(todo.id)
          }
          .swipeActions {
            Button("Erase", systemImage: "trash", role: .destructive) {
              model.eraseTodo(todo.id)
            }
          }
          .contextMenu {
            DeletedTodoRowContextMenu(
              onPutBack: { model.putBackTodo(todo.id) },
              onErase: { model.eraseTodo(todo.id) },
            )
          }
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
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  NavigationStack {
    DeletedDetailView()
  }
  .accentColor(.pink)
}
