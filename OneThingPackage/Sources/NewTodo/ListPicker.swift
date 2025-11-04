import AppDatabase
import AppModels
import SQLiteData
import SwiftUI
import Utilities

struct ListPicker: View {
  @Bindable var model: NewTodoModel
  
  var body: some View {
    Picker("List", systemImage: "list.bullet.circle.fill", selection: $model.listID) {
      ForEach(model.selectableLists) { list in
        Label {
          Text(list.name)
        } icon: {
          Image(systemName: "list.bullet.circle.fill")
            .foregroundStyle(list.color.swiftUIColor ?? .gray)
        }
      }
    } currentValueLabel: {
      Text(selectedTitle)
    }
    .pickerStyle(.navigationLink)
    .listItemTint(selectedTint)
  }
  
  var selectedTint: Color {
    model.selectedList?.color.swiftUIColor ?? .gray
  }
  
  var selectedTitle: String {
    model.selectedList?.name ?? ""
  }
}

#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset()
    )
  }

  let model = NewTodoModel(listID: 1)
  NavigationStack {
    List {
      ListPicker(model: model)
    }
  }
}
