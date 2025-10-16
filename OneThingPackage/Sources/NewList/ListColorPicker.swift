import SwiftUI


struct ListColorPicker: View {
  @Binding var colorIndex: Int
  
  var body: some View {
    LazyVGrid(
      columns: (1...5).map {_ in GridItem(.flexible()) }
    ) {
      ForEach(0...9, id: \.self) { i in
        Circle()
          .fill(Color.all[i])
          .scaleEffect(colorIndex == i ? 1 : sqrt(0.5))
          .opacity(colorIndex == i ? 1 : 0.5)
          .onTapGesture {
            withAnimation {
              colorIndex = i
            }
          }
      }
    }
  }
}
