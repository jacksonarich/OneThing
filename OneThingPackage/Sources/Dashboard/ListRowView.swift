import AppDatabase
import AppModels
import NewList
import Search
import SQLiteData
import SwiftUI
import Utilities


struct ListRowView: View {
  let name: String
  let color: Color
  let count: Int
  
  init(name: String, color: Color, count: Int) {
    self.color = color
    self.count = count
    self.name = name
  }

  var body: some View {
    HStack {
      ListLabel(name: name, color: color)
      Spacer()
      ListCount(count)
    }
  }
}


private struct ListCount: View {
  let count: Int
  
  init(_ count: Int) {
    self.count = count
  }
  
  @Environment(\.editMode) var editMode
  var body: some View {
    ZStack {
      HStack {
        Text("\(count)")
          .foregroundStyle(Color.gray)
        Image(systemName: "chevron.right")
          .font(.footnote.bold())
          .foregroundStyle(Color(.tertiaryLabel))
      }
      .opacity(isEditing ? 0.0001 : 1)
      Image(systemName: "pencil")
        .opacity(isEditing ? 1 : 0.0001)
    }
  }
  
  var isEditing: Bool {
    editMode?.wrappedValue.isEditing ?? false
  }
}


#Preview {
  NavigationStack {
    List {
      ListRowView(
        name: "Grocery",
        color: .green,
        count: 5
      )
    }
    .toolbar {
      EditButton()
    }
  }
  .accentColor(.pink)
}
