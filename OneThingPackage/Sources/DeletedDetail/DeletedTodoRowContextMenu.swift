import AppModels
import SwiftUI


struct DeletedTodoRowContextMenu: View {
  let currentListID: TodoList.ID
  let movableLists: [TodoList]
  let onPutBack: () -> Void
  let onErase: () -> Void
  let onMove: (TodoList.ID) -> Void
  
  public init(
    currentListID: TodoList.ID,
    movableLists: [TodoList],
    onPutBack: @escaping () -> Void,
    onErase: @escaping () -> Void,
    onMove: @escaping (TodoList.ID) -> Void
  ) {
    self.currentListID = currentListID
    self.movableLists = movableLists
    self.onPutBack = onPutBack
    self.onErase = onErase
    self.onMove = onMove
  }
  
  public var body: some View {
    Button(action: onPutBack) {
      Label("Put Back", systemImage: "arrow.uturn.backward")
    }
    Button(action: onErase) {
      Label("Erase", systemImage: "trash")
    }
    Menu {
      ForEach(movableLists) { list in
        Button {
          onMove(list.id)
        } label: {
          Label(list.name, systemImage: list.id == currentListID ? "checkmark" : "")
        }
      }
    } label: {
      Label("Move To...", systemImage: "folder")
    }
  }
}
