import AppDatabase
import SQLiteData
import SwiftUI
import Utilities


public struct InProgressDetailView: View {
  @State private var model = InProgressDetailModel()
  
  public init() {}
  
  public var body: some View {
    ZStack {
      List {
        ForEach(model.todoGroups) { group in
          Section {
            ForEach(group.todos) { todo in
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
          } header: {
            Text(group.list.name) 
              .foregroundStyle(group.list.color.swiftUIColor ?? .gray)
              .font(.title2)
              .fontDesign(.rounded)
              .bold()
              .lineLimit(2)
          }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
      .listStyle(.plain)
      if model.todoGroups.isEmpty {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
          .fontDesign(.rounded)
      }
    }
    .navigationTitle("In Progress")
    .navigationBarTitleDisplayMode(.large)
    .background(Color(.systemGroupedBackground))
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  NavigationStack {
    InProgressDetailView()
  }
  .accentColor(.pink)
}
