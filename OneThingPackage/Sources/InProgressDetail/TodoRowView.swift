import AppDatabase
import AppModels
import SQLiteData
import SwiftUI


struct TodoRowView: View {
  let model: InProgressDetailModel
  let todo:  Todo
  
  init(
    model: InProgressDetailModel,
    todo:  Todo
  ) {
    self.model = model
    self.todo  = todo
  }
  
  var checkboxImage: String {
    todo.isTransitioning ? "checkmark.circle" : "circle"
//    switch (todo.completeDate != nil || todo.isTransitioning, todo.deleteDate != nil) {
//    case (false, false): return "circle"
//    case (true,  false): return "checkmark.circle"
//    case (false, true ): return "xmark.circle"
//    case (true,  true ): return "questionmark.circle"
//    }
  }
  
  var isInProgress: Bool {
    todo.completeDate == nil && todo.deleteDate == nil
  }
  
  var deadline: String? {
    if let date = todo.deadline {
      "Due " + date.formatted(.dateTime.month(.abbreviated).day())
    } else {
      nil
    }
  }
  
  var body: some View {
    Button {
      model.toggleComplete(todo.id, complete: todo.isTransitioning == false)
//      if isInProgress {
//        model.completeTodo(todo)
//      } else {
//        model.putBackTodo(todo)
//      }
    } label: {
      HStack(alignment: .top) {
        Image(systemName: checkboxImage)
          .foregroundStyle(todo.isTransitioning ? .primary : .secondary)
          .font(.title2)
          .padding(.trailing, 5)
        VStack(alignment: .leading) {
          Text(todo.title)
            .foregroundStyle(Color.primary)
            .fontDesign(.rounded)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .strikethrough(todo.isTransitioning)
          if let deadline {
            Text(deadline)
              .foregroundStyle(Color.secondary)
              .font(.callout)
              .fontDesign(.rounded)
              .animation(.default, value: todo.deadline)
          }
        }
        Spacer(minLength: 0)
      }
      .animation(nil, value: todo.isTransitioning)
      .contentShape(Rectangle())
    }
    .buttonStyle(.borderless)
    .swipeActions(edge: .trailing) {
      if isInProgress {
        Button("Delete", systemImage: "xmark", role: .destructive) {
          model.deleteTodo(todo)
        }
        .tint(.red)
      }
    }
    .contextMenu {
      if isInProgress {
        Button {
          model.toggleComplete(todo.id, complete: todo.isTransitioning == false)
        } label: {
          Label("Complete", systemImage: "checkmark")
        }
        Button {
          model.deleteTodo(todo)
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
  let model = InProgressDetailModel()
  TodoRowView(
    model: model,
    todo: Todo(
      id: 1,
      title: "Todo title",
      notes: "",
      deadline: nil,
      frequencyUnitIndex: nil,
      frequencyCount: nil,
      createDate: .now,
      modifyDate: .now,
      completeDate: nil,
      deleteDate: nil,
      order: "",
      listID: 1,
      isTransitioning: true
    )
  )
}
