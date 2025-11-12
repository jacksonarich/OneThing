import AppDatabase
import SQLiteData
import SwiftUI
import Utilities


public struct ScheduledDetailView: View {
  @State private var model = ScheduledDetailModel()
  
  public init() {}
  
  public var body: some View {
    ZStack {
      List {
        ForEach(model.todos) { todo in
          TodoRowButton(
            todo: todo,
            subtitle: todo.deadline.map { "Due \($0.relativeString)" }
          ) {
            model.todoRowTapped(todo.id, isTransitioning: todo.isTransitioning)
          }
          .swipeActions {
            Button("Delete", systemImage: "xmark", role: .destructive) {
              model.deleteTodo(todo.id)
            }
          }
          .contextMenu {
            TodoRowContextMenu(
              currentListID: todo.listID,
              movableLists: model.movableLists,
              onTap: { model.todoRowTapped(todo.id, isTransitioning: todo.isTransitioning) },
              onDelete: { model.deleteTodo(todo.id) },
              onMove: { listID in model.moveTodo(todo.id, to: listID) }
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
      }
    }
    .navigationTitle("Scheduled")
    .navigationBarTitleDisplayMode(.large)
    .background(Color(.systemGroupedBackground))
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  NavigationStack {
    ScheduledDetailView()
  }
  .accentColor(.pink)
}
