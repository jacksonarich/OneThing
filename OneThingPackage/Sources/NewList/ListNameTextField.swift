import SwiftUI


struct ListNameTextField: View {
  @Binding var name: String
  @Binding var colorIndex: Int
  @FocusState var isFocused: Bool
  
  var body: some View {
    TextField("List Name", text: $name)
      .multilineTextAlignment(.center)
      .font(.system(size: 25, weight: .bold, design: .rounded))
      .tint(.all[colorIndex])
      .padding(.vertical, 5)
      .focused($isFocused)
      .onAppear {
        isFocused = true
      }
  }
}
