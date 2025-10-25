import AppModels
import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


struct TodoRowView: View {
  let model: DeletedDetailModel
  let todo:  Todo
  
  init(
    model: DeletedDetailModel,
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
  
  var isDeleted: Bool {
    todo.deleteDate != nil
  }
  
  var deleteDate: String {
    if let date = todo.deleteDate {
      "Deleted " + date.formatted(.dateTime.month(.abbreviated).day())
    } else {
      "Not Deleted"
    }
  }
  
  var body: some View {
    Button {
      if isDeleted {
        model.putBackTodo(id: todo.id)
      }
    } label: {
      HStack(alignment: .top) {
        Image(systemName: checkboxImage)
          .foregroundStyle(.secondary)
          .font(.title2)
          .padding(.trailing, 5)
        VStack(alignment: .leading) {
          Text(todo.title)
            .foregroundStyle(Color.primary)
            .fontDesign(.rounded)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
          Text(deleteDate)
            .foregroundStyle(Color.secondary)
            .font(.callout)
            .fontDesign(.rounded)
        }
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.borderless)
    .swipeActions(edge: .trailing) {
      if isDeleted {
        Button("Erase", systemImage: "trash", role: .destructive) {
          model.eraseTodo(id: todo.id)
        }
        .tint(.gray)
      }
    }
    .contextMenu {
      if isDeleted {
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
