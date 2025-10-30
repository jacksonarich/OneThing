import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


// When you complete a recurring todo, it gets rescheduled.
// The normal checkmark + strikethrough animation plays, in addition to a rotating hourglass icon that tells the user the deadline is advancing.
// After the 2 seconds are up, instead of disappearing, the todo animates back to normal, and the spinning icon fades out.
// When you put back a todo while it's rescheduling, it will un-reschedule – that is, the deadline will revert to the previous date. This previous date must be stored in memory along with the todo ID.


public struct InProgressDetailView: View {
  @State private var model = InProgressDetailModel()
  
  public init() {}
  
  public var body: some View {
    ZStack {
      List {
        ForEach(model.todoGroups) { group in
          let listColor = Color.all[group.list.colorIndex]
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
              .foregroundStyle(listColor)
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
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset()
    )
  }
  NavigationStack {
    InProgressDetailView()
  }
  .accentColor(.pink)
}
