import SQLiteData
import SwiftUI

import AppDatabase
import AppModels
import Utilities


public struct NewTodoView: View {
  @State var model: NewTodoModel
  @Environment(\.dismiss) var dismiss
  
  public init(model: NewTodoModel) {
    self.model = model
  }
  
  public var body: some View {
    List {
      Section {
        TextField("Title", text: $model.title)
        TextField("Notes", text: $model.notes)
      }
      Section {
        Toggle(isOn: Binding(
          get: { model.deadline != nil },
          set: { model.toggleDeadline(isOn: $0) }
        )) {
          Text("Due Date")
        }
        if let deadline = model.deadline {
          DatePicker(
            "",
            selection: Binding(
              get: { deadline },
              set: { model.deadline = $0 }
            ),
            in: .now...
          )
          .datePickerStyle(.graphical)
          // frequency picker
        }
      }
      Section {
        ListPicker(model: model)
      }
    }
    .navigationTitle("New Item")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Cancel") {
          dismiss()
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button("Done") {
          model.createTodo()
          dismiss()
        }
        .disabled(model.title.trimmed().isEmpty)
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
    NewTodoView(model: .init(
      listID: 1,
//      listName: "List Name",
//      listColorIndex: 0
    ))
  }
  .accentColor(.pink)
}
