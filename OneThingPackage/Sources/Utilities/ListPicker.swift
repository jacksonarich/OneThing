import AppModels
import SQLiteData
import SwiftUI


public struct ListPicker: View {
  @Binding var listID: TodoList.ID?
  let selectableLists: [TodoList]
  
  public init(
    listID: Binding<TodoList.ID?>,
    selectableLists: [TodoList]
  ) {
    self._listID = listID
    self.selectableLists = selectableLists
  }
  
  public var body: some View {
    Picker(selection: $listID) {
      ListLabel(
        name: "Select...",
        color: .gray.opacity(0.5)
      )
      .tag(nil as TodoList.ID?)
      ForEach(selectableLists) { list in
        ListLabel(
          name: list.name,
          color: list.color.swiftUIColor ?? .gray
        )
        .tag(list.id)
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
  }
  
  var selectedList: TodoList? {
    selectableLists.first { $0.id == listID }
  }
  
  var selectedTint: Color {
    selectedList?.color.swiftUIColor ?? .gray.opacity(0.5)
  }
  
  var selectedTitle: String {
    selectedList?.name ?? "Select..."
  }
}


#Preview {
  @Previewable @State var listID: TodoList.ID? = nil
  let selectableLists: [TodoList] = [
    .init(id: 1, name: "A", color: .red, createDate: .now, modifyDate: .now),
    .init(id: 2, name: "B", color: .green, createDate: .now, modifyDate: .now),
    .init(id: 3, name: "C", color: .blue, createDate: .now, modifyDate: .now)
  ]
  NavigationStack {
    List {
      ListPicker(listID: $listID, selectableLists: selectableLists)
    }
  }
  .accentColor(.pink)
}
