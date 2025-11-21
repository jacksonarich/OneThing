import AppModels
import SwiftUI


public struct ListNameTextField: View {
  @Binding var name: String
  let color: ListColor
  @FocusState private var isFocused: Bool
  
  public init(name: Binding<String>, color: ListColor) {
    self._name = name
    self.color = color
  }
  
  public var body: some View {
    TextField("List Name", text: $name)
      .multilineTextAlignment(.center)
      .font(.system(size: 25, weight: .bold, design: .rounded))
      .tint(color.swiftUIColor ?? .gray)
      .padding(.vertical, 5)
      .focused($isFocused)
      .onFirstAppear {
        isFocused = true
      }
  }
}

#Preview {
  @Previewable @State var name = "List name"
  List {
    ListNameTextField(name: $name, color: .cyan)
  }
  }
