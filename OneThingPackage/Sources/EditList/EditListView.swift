import AppDatabase
import AppModels
import SQLiteData
import SwiftUI
import Utilities


public struct EditListView: View {
  @State private var model: EditListModel
  @Environment(\.dismiss) var dismiss
  
  public init(listID: TodoList.ID) {
    self.model = EditListModel(listID: listID)
  }
  
  public var body: some View {
    List {
      Section {
        ListNameTextField(
          name: $model.name,
          color: model.color
        )
      }
      Section {
        ListColorPicker(
          color: $model.color
        )
      }
      Section {
        Button(role: .destructive) {
          model.showDialog()
        } label: {
          HStack {
            Spacer()
            Text("Delete")
              .bold()
            Spacer()
          }
        }
        .confirmationDialog(
          "Delete List?",
          isPresented: $model.showAlert,
          titleVisibility: .visible
        ) {
          Button("Delete List", role: .destructive) {
            model.deleteList()
            dismiss()
          }
        } message: {
          Text("All things in this list will be deleted.")
        }
      }
    }
    .navigationTitle("Edit List")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Cancel") {
          dismiss()
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button("Done") {
          model.editList()
          dismiss()
        }
        .disabled(model.name.trimmed().isEmpty)
      }
    }
    .task(model.fetch)
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
      EditListView(listID: 1)
    }
    .accentColor(.pink)
  }
}
