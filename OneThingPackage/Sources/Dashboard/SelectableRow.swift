import Utilities
import SwiftUI


struct SelectableRow<T>: View where T: View {
  @Binding var isSelected: Bool
  @Environment(\.editMode) var editMode
  @State private var iconWidth: CGFloat = 0
  let content: () -> T
  
  var body: some View {
    Button {
      isSelected.toggle()
    } label: {
      HStack(spacing: 15) {
        checkbox
          .offset(x: editMode.isEditing ? 0 : -40)
          .opacity(editMode.isEditing ? 1 : 0.0001)
          .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
          } action: { v2 in
            iconWidth = v2
          }
        content()
          .offset(x: editMode.isEditing ? 0 : -(iconWidth + 15))
      }
    }
    .buttonStyle(.plain)
  }
  
  var checkbox: some View {
    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
      .font(.body)
      .imageScale(.large)
      .foregroundStyle(isSelected ? Color.accentColor : Color.gray.opacity(0.5))
  }
}
