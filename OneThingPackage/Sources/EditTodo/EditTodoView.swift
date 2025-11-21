import AppDatabase
import AppModels
import SQLiteData
import SwiftUI
import Utilities


public struct EditTodoView: View {
  @Bindable var model: EditTodoModel
  @Environment(\.dismiss) var dismiss
  
  public init(model: EditTodoModel) {
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
    .navigationTitle("Edit Thing")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Cancel") {
          dismiss()
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button("Done") {
          model.editTodo()
          dismiss()
        }
        .disabled(
          model.title.trimmed().isEmpty
          || model.listID == nil
        )
      }
    }
    .onFirstAppear(model.fetch)
  }
}


#Preview {
  @Previewable @State var showSheet = true
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  let model = EditTodoModel(todoID: 1)
  Button("Show") {
    showSheet = true
  }
  .sheet(isPresented: $showSheet) {
    NavigationStack {
      EditTodoView(model: model)
    }
    .accentColor(.pink)
  }
}
