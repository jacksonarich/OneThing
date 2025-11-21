import AppDatabase
import EditTodo
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
            subtitle: todo.deadline.map { "Due \($0.relativeString)" },
            isSubtitleHighlighted: todo.isOverdue,
            checkboxImage: todo.transition == nil ? .inProgressCheckbox : .completedCheckbox
          ) {
            model.todoRowTapped(todo.id, shouldTransition: todo.transition == nil)
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
              onTap: { model.todoRowTapped(todo.id, shouldTransition: todo.transition == nil) },
              onDelete: { model.deleteTodo(todo.id) },
              onEdit: { model.editTodo(todo.id) },
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
    .sheet(item: $model.editingTodoID) { todoID in
      NavigationStack {
        EditTodoView(todoID: todoID)
      }
    }
    .sensoryFeedback(.impact(flexibility: .solid), trigger: model.hapticID)
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
