import AppModels
import SwiftUI


struct ListColorPicker: View {
  @Binding var color: ListColor
  
  var body: some View {
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
