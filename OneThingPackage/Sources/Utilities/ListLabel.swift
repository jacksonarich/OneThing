import SwiftUI


public struct ListLabel: View {
  let name: String
  let color: Color
  
  public init(
    name: String,
    color: Color
  ) {
    self.name = name
    self.color = color
  }
  
  public var body: some View {
    Label {
      Text(name)
        .foregroundStyle(Color.primary)
        .lineLimit(2)
    } icon: {
      Image(systemName: "circle.fill")
        .font(.title2)
        .foregroundStyle(color)
    }
    .padding(.vertical, 5)
  }
}


#Preview {
  List {
    ListLabel(
      name: "Grocery",
      color: .green
    )
  }
}
