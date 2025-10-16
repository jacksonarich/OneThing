import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


public struct NewListView: View {
  @State var model: NewListModel
  @Environment(\.dismiss) var dismiss
  
  public init(model: NewListModel) {
    self.model = model
  }
  
  public var body: some View {
    List {
      Section {
        ListNameTextField(
          name: $model.name,
          colorIndex: $model.colorIndex
        )
      }
      Section {
        ListColorPicker(
          colorIndex: $model.colorIndex
        )
      }
    }
    .navigationTitle("New List")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button("Cancel") {
          dismiss()
        }
      }
      ToolbarItem(placement: .topBarTrailing) {
        Button("Done") {
          model.createList()
          dismiss()
        }
        .disabled(model.name.trimmed().isEmpty)
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
    NewListView(model: .init())
  }
  .accentColor(.pink)
}
