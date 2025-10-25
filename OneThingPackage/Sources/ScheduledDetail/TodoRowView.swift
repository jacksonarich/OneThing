import AppDatabase
import AppModels
import SQLiteData
import SwiftUI


struct TodoRowView: View {
  let model: ScheduledDetailModel
  let todo:  Todo
  
  init(
    model: ScheduledDetailModel,
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
  
  var isInProgress: Bool {
    todo.completeDate == nil && todo.deleteDate == nil
  }
  
  var isHighlighted: Bool {
    model.highlightedTodoIDs.contains(todo.id)
  }
  
  var deadline: String {
    if let date = todo.deadline {
      "Due " + date.formatted(.dateTime.month(.abbreviated).day())
    } else {
      "No Deadline"
    }
  }
  
  var body: some View {
    Button {
      if isInProgress {
        model.completeTodo(id: todo.id)
      } else {
        model.putBackTodo(id: todo.id)
      }
    } label: {
      HStack(alignment: .top) {
        Image(systemName: checkboxImage)
          .foregroundStyle(isHighlighted ? .primary : .secondary)
          .font(.title2)
          .padding(.trailing, 5)
          .animation(nil, value: isHighlighted)
        VStack(alignment: .leading) {
          Text(todo.title)
            .foregroundStyle(Color.primary)
            .fontDesign(.rounded)
            .strikethrough(isHighlighted)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .animation(.default, value: isHighlighted)
          Text(deadline)
            .foregroundStyle(Color.secondary)
            .font(.callout)
            .fontDesign(.rounded)
        }
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
