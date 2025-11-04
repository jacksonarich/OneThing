import AppModels
import SwiftUI


struct ListRowView: View {
  @State var model: DashboardModel
  let row: TodoListWithCount
  
  var body: some View {
    HStack {
      Group {
        Image(systemName: "circle.fill")
          .font(.largeTitle)
          .foregroundStyle(row.list.color.swiftUIColor ?? .gray)
        Text(row.list.name)
          .foregroundStyle(Color.primary)
          .fontDesign(.rounded)
          .lineLimit(2)
      }
      .opacity(model.isEditing ? 0.5 : 1)
      Spacer()
      ZStack {
        HStack {
          Text("\(row.count)")
            .foregroundStyle(Color.gray)
            .fontDesign(.rounded)
          Image(systemName: "chevron.right")
            .font(.footnote.bold())
            .foregroundStyle(Color(.tertiaryLabel))
        }
        .opacity(model.isEditing ? 0.0001 : 1)
        Image(systemName: "pencil")
          .opacity(model.isEditing ? 1 : 0.0001)
      }
    }
    .contentShape(Rectangle())
  }
}
