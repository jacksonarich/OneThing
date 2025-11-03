import SQLiteData
import SwiftUI

import AppDatabase
import NewTodo
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
          TodoRowButton(
            todo: todo,
            subtitle: todo.deadline.map { "Due \($0.subtitle)" }
          ) {
            model.toggleComplete(todo.id, complete: todo.isTransitioning == false)
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
              onToggleComplete: { model.toggleComplete(todo.id, complete: todo.isTransitioning == false) },
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
          .fontDesign(.rounded)
      }
    }
    .toolbar {
      ToolbarItem(placement: .bottombar) {
        Text("New Item")
      }
    }
    .navigationTitle(model.list?.name ?? "Unknown")
    .navigationBarTitleDisplayMode(.large)
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
    ListDetailView(model: .init(listID: 1))
  }
  .accentColor(.pink)
}
