import AppDatabase
import Schema
import SQLiteData
import SwiftUI


struct TodoRowView: View {
  let model: DashboardModel
  let todo:  Todo
  
  init(
    model: DashboardModel,
    todo:  Todo
  ) {
    self.model = model
    self.todo  = todo
  }
  
  var checkboxImage: String {
    switch (todo.completeDate != nil, todo.deleteDate != nil) {
    case (false, false): return "square"
    case (true,  false): return "checkmark.square"
    case (false, true ): return "xmark.square"
    case (true,  true ): return "questionmark.square"
    }
  }
  
  var isInProgress: Bool {
    todo.completeDate == nil && todo.deleteDate == nil
  }
  
  var isHighlighted: Bool {
    model.highlightedTodoIDs.contains(todo.id)
  }
  
  var body: some View {
    Button {
      if isInProgress {
        model.completeTodo(id: todo.id)
      } else {
        model.putBackTodo(id: todo.id)
      }
    } label: {
      HStack {
        Image(systemName: checkboxImage)
          .foregroundStyle(isHighlighted ? .primary : .secondary)
          .font(.title2)
          .padding(.trailing, 5)
          .animation(nil, value: isHighlighted)
        Text(todo.title)
          .foregroundStyle(Color.primary)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
        Spacer(minLength: 0)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.borderless)
    .swipeActions(edge: .trailing) {
      if isInProgress {
        Button("Delete", systemImage: "xmark", role: .destructive) {
          model.deleteTodo(id: todo.id)
        }
        .tint(.red)
      }
    }
    .contextMenu {
      if isInProgress {
        Button {
          model.completeTodo(id: todo.id)
        } label: {
          Label("Complete", systemImage: "checkmark")
        }
        Button {
          model.deleteTodo(id: todo.id)
        } label: {
          Label("Delete", systemImage: "xmark")
        }
        Menu {
          ForEach(model.movableLists) { list in
            Button {
              model.moveTodo(id: todo.id, to: list.id)
            } label: {
              Label(list.name, systemImage: list.id == todo.listID ? "checkmark" : "")
            }
          }
        } label: {
          Label("Move To...", systemImage: "arrowshape.turn.up.right")
        }
      }
    }
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
    DashboardView(model: .init(searchText: "e"))
  }
  .accentColor(.pink)
}
