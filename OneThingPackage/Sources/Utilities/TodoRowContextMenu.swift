import AppModels
import SwiftUI

public struct TodoRowContextMenu: View {
  let currentListID: TodoList.ID
  let movableLists: [TodoList]
  let onToggleComplete: () -> Void
  let onDelete: () -> Void
  let onMove: (TodoList.ID) -> Void
  
  public init(
    currentListID: TodoList.ID,
    movableLists: [TodoList],
    onToggleComplete: @escaping () -> Void,
    onDelete: @escaping () -> Void,
    onMove: @escaping (TodoList.ID) -> Void
  ) {
    self.currentListID = currentListID
    self.movableLists = movableLists
    self.onToggleComplete = onToggleComplete
    self.onDelete = onDelete
    self.onMove = onMove
  }
  
  public var body: some View {
    Button(action: onToggleComplete) {
      Label("Complete", systemImage: "checkmark")
    }
    Button(action: onDelete) {
      Label("Delete", systemImage: "xmark")
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
