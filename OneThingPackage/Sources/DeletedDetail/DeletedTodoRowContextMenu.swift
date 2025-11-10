import AppModels
import SwiftUI


struct DeletedTodoRowContextMenu: View {
  let onPutBack: () -> Void
  let onErase: () -> Void
  
  public init(
    onPutBack: @escaping () -> Void,
    onErase: @escaping () -> Void
  ) {
    self.onPutBack = onPutBack
    self.onErase = onErase
  }
  
  public var body: some View {
    Button(action: onPutBack) {
      Label("Put Back", systemImage: "arrow.uturn.backward")
    }
    Button(action: onErase) {
      Label("Erase", systemImage: "trash")
    }
  }
}
