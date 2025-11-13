import AppDatabase
import SQLiteData
import SwiftUI
import Utilities


public struct CompletedDetailView: View {
  @State private var model = CompletedDetailModel()
  
  public init() {}
  
  public var body: some View {
    ZStack {
      List {
        ForEach(model.todos) { todo in
          TodoRowButton(
            todo: todo,
            subtitle: todo.completeDate.map { "Completed \($0.relativeString)" },
            checkboxImage: todo.transition == nil ? .completedCheckbox : .inProgressCheckbox
          ) {
            model.putBackTodo(todo.id)
          }
          .swipeActions {
            Button("Delete", systemImage: "xmark", role: .destructive) {
              model.deleteTodo(todo.id)
            }
          }
          .contextMenu {
            Button {
              model.putBackTodo(todo.id)
            } label: {
              Label("Put Back", systemImage: "arrow.uturn.backward")
            }
            Button {
              model.deleteTodo(todo.id)
            } label: {
              Label("Delete", systemImage: "xmark")
            }
          }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
      .listStyle(.plain)
      if model.todos.isEmpty {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
      }
    }
    .navigationTitle("Completed")
    .navigationBarTitleDisplayMode(.large)
    .background(Color(.systemGroupedBackground))
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  NavigationStack {
    CompletedDetailView()
  }
  .accentColor(.pink)
}
