import AppDatabase
import AppModels
import SQLiteData
import SwiftUI
import Utilities


public struct NewTodoView: View {
  @State private var model: NewTodoModel
  @Environment(\.dismiss) var dismiss
  @FocusState private var isFocused: Bool
  
  public init(listID: TodoList.ID? = nil) {
    self.model = NewTodoModel(listID: listID)
  }
  
  public var body: some View {
    List {
      Section {
        TextField("Title", text: $model.title)
          .focused($isFocused)
          .onFirstAppear {
            isFocused = true
          }
        TextField("Notes", text: $model.notes)
      }
      Section {
        Toggle(isOn: Binding(
          get: { model.deadline != nil },
          set: { isOn in
            withAnimation {
              model.toggleDeadline(isOn: isOn)
            }
          }
        )) {
          Label("Date", systemImage: "calendar")
        }
        .tint(.accentColor)
        if let deadline = model.deadline {
          DatePicker(
            "",
            selection: Binding(
              get: { deadline },
              set: { model.deadline = $0 }
            ),
            in: .now...
          )
          .datePickerStyle(.compact)
          FrequencyPicker(
            frequencySelection: $model.frequencySelection,
            customFrequency: $model.customFrequency,
            actualFrequency: model.actualFrequency
          )
        }
      }
      Section {
        ListPicker(
          listID: $model.listID,
          selectableLists: model.selectableLists
        )
      }
    }
    .navigationTitle("New Thing")
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
        .disabled(
          model.title.trimmed().isEmpty
          || model.listID == nil
        )
      }
    }
  }
}


#Preview {
  @Previewable @State var showSheet = true
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  Button("Show") {
    showSheet = true
  }
  .sheet(isPresented: $showSheet) {
    NavigationStack {
      NewTodoView()
    }
    .accentColor(.pink)
  }
}
