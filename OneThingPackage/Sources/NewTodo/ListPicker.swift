import AppDatabase
import AppModels
import SQLiteData
import SwiftUI
import Utilities

struct ListPicker: View {
  @Bindable var model: NewTodoModel
  
  var body: some View {
    Picker(
      selection: $model.listID
    ) {
      ForEach(model.selectableLists) { list in
        ListLabel(
          name: list.name,
          color: list.color.swiftUIColor ?? .gray
        )
      }
    } label: {
      ListLabel(
        name: "List",
        color: selectedTint
      )
    } currentValueLabel: {
      Text(selectedTitle)
        .lineLimit(1)
    }
    .pickerStyle(.navigationLink)
    .listItemTint(selectedTint)

//    Picker("List", systemImage: "circle.fill", selection: $model.listID) {
//      ForEach(model.selectableLists) { list in
//        ListLabel(
//          name: list.name,
//          color: list.color.swiftUIColor ?? .gray
//        )
//      }
//    } currentValueLabel: {
//      Text(selectedTitle)
//        .lineLimit(1)
//    }
//    .pickerStyle(.navigationLink)
//    .listItemTint(selectedTint)
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
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }

  let model = NewTodoModel(listID: 1)
  NavigationStack {
    List {
      ListPicker(model: model)
    }
  }
  .accentColor(.pink)
}
