import AppModels
import SwiftUI


public struct ListColorPicker: View {
  @Binding var color: ListColor
  
  public init(color: Binding<ListColor>) {
    self._color = color
  }
  
  public var body: some View {
    LazyVGrid(
      columns: (1...5).map {_ in GridItem(.flexible()) }
    ) {
      ForEach(ListColor.all, id: \.self) { c in
        Circle()
          .fill(c.swiftUIColor ?? .clear)
          .scaleEffect(color == c ? 1 : sqrt(0.5))
          .opacity(color == c ? 1 : 0.5)
          .onTapGesture {
            withAnimation {
              color = c
            }
          }
      }
    }
  }
}

#Preview {
  @Previewable @State var color = ListColor.blue
  ListColorPicker(color: $color)
}
