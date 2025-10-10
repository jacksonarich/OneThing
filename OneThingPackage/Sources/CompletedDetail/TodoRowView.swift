import AppDatabase
import Schema
import SQLiteData
import SwiftUI


struct TodoRowView: View {
  let model: CompletedDetailModel
  let todo:  Todo
  
  init(
    model: CompletedDetailModel,
    todo:  Todo
  ) {
    self.model = model
    self.todo  = todo
  }
  
  var checkboxImage: String {
    switch (todo.completeDate != nil, todo.deleteDate != nil) {
    case (false, false): return "circle"
    case (true,  false): return "checkmark.circle"
    case (false, true ): return "xmark.circle"
    case (true,  true ): return "questionmark.circle"
    }
  }
  
  var isCompleted: Bool {
    todo.completeDate != nil
  }
  
  var isHighlighted: Bool {
    model.highlightedTodoIDs.contains(todo.id)
  }
  
  var body: some View {
    Button {
      if isCompleted {
        model.putBackTodo(id: todo.id)
      } else {
        model.completeTodo(id: todo.id)
      }
    } label: {
      HStack {
        Image(systemName: checkboxImage)
          .foregroundStyle(isHighlighted ? .primary : .secondary)
          .font(.title2)
          .padding(.trailing, 5)
          .animation(nil, value: isHighlighted)
        Text(todo.title)
          .foregroundStyle(isHighlighted ? Color.accentColor : Color.primary)
          .fontDesign(.rounded)
          .lineLimit(2)
          .multilineTextAlignment(.leading)
          .animation(.default, value: isHighlighted)
        Spacer(minLength: 0)
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.borderless)
    .swipeActions(edge: .trailing) {
      if isCompleted {
        Button("Erase", systemImage: "trash", role: .destructive) {
          model.eraseTodo(id: todo.id)
        }
        .tint(.gray)
      }
    }
    .contextMenu {
      if isCompleted {
        Button {
          model.putBackTodo(id: todo.id)
        } label: {
          Label("Put Back", systemImage: "arrow.uturn.backward")
        }
        Button {
          model.eraseTodo(id: todo.id)
        } label: {
          Label("Erase", systemImage: "trash")
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
