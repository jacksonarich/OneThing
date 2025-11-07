import SQLiteData
import SwiftUI

import AppDatabase
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
            subtitle: todo.completeDate.map { "Completed \($0.subtitle)" }
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
            Menu {
              ForEach(model.movableLists) { list in
                Button {
                  model.moveTodo(todo.id, to: list.id)
                } label: {
                  Label(list.name, systemImage: list.id == todo.listID ? "checkmark" : "")
                }
              }
            } label: {
              Label("Move To...", systemImage: "folder")
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
          .fontDesign(.rounded)
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
