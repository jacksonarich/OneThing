import AppModels
import SwiftUI


public struct TodoRowContextMenu: View {
  let currentListID: TodoList.ID
  let movableLists: [TodoList]
  let onTap: () -> Void
  let onDelete: () -> Void
  let onEdit: () -> Void
  let onMove: (TodoList.ID) -> Void
  
  public init(
    currentListID: TodoList.ID,
    movableLists: [TodoList],
    onTap: @escaping () -> Void,
    onDelete: @escaping () -> Void,
    onEdit: @escaping () -> Void,
    onMove: @escaping (TodoList.ID) -> Void
  ) {
    self.currentListID = currentListID
    self.movableLists = movableLists
    self.onTap = onTap
    self.onDelete = onDelete
    self.onEdit = onEdit
    self.onMove = onMove
  }
    
  public var body: some View {
    Button(action: onTap) {
      Label("Complete", systemImage: "checkmark")
    }
    Button(action: onDelete) {
      Label("Delete", systemImage: "xmark")
    }
    Button(action: onEdit) {
      Label("Edit", systemImage: "pencil")
    }
    Picker("Move To...", systemImage: "folder", selection: Binding(
      get: { currentListID },
      set: { onMove($0) }
    )) {
      ForEach(movableLists) { list in
        Text(list.name)
          .tag(list.id)
      }
    }
    .pickerStyle(.menu)
  }
}


#Preview {
  @Previewable @State var currentListID: TodoList.ID = 1
  NavigationStack {
    List {
      Text("Todo")
        .contextMenu {
          TodoRowContextMenu(
            currentListID: currentListID,
            movableLists: [
              .init(id: 1, name: "List A", color: .red, createDate: .now, modifyDate: .now),
              .init(id: 2, name: "List B", color: .green, createDate: .now, modifyDate: .now),
              .init(id: 3, name: "List C", color: .blue, createDate: .now, modifyDate: .now),
            ],
            onTap: {},
            onDelete: {},
            onEdit: {},
            onMove: { currentListID = $0 }
          )
        }
    }
  }
  .accentColor(.pink)
}
