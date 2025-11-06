import SQLiteData
import SwiftUI

import AppDatabase
import AppModels
import NewList
import Search
import Utilities


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
          .fontDesign(.rounded)
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


struct ListRowView: View {
  let color: Color
  let count: Int
  let name: String
  
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


#Preview {
  @Previewable @State var editMode = EditMode.inactive
  NavigationStack {
    List {
      ListRowView(
        name: "List",
        color: .purple,
        count: 5
      )
      Button("Toggle Edit") {
        withAnimation {
          editMode = editMode == .inactive ? .active : .inactive
        }
      }
    }
    .environment(\.editMode, $editMode)
  }
  .accentColor(.pink)
}
