import SwiftUI


public struct ListLabel: View {
  let color: Color
  let name: String
  
  public init(name: String, color: Color) {
    self.color = color
    self.name = name
  }
  
  public var body: some View {
    Label {
      Text(name)
        .foregroundStyle(Color.primary)
        .fontDesign(.rounded)
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
    ListLabel(name: "Grocery", color: .green)
  }
}
