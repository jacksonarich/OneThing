import Schema
import SwiftUI


struct ListCellView: View {
  @State var model: DashboardModel
  let name: String
  let image: String
  let color: Color
  let count: Int?
  
  var body: some View {
    if !model.hiddenLists.contains(name) {
      Button {
        model.listCellTapped(name: name)
      } label: {
        label
      }
    }
  }
  
  var label: some View {
    HStack(alignment: .firstTextBaseline) {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: image + ".circle.fill")
          .font(.largeTitle)
          .symbolRenderingMode(.palette)
          .foregroundStyle(.white, color)
        Text(name)
          .foregroundStyle(.gray)
          .font(.headline)
          .fontDesign(.rounded)
          .bold()
          .padding(.leading, 4)
      }
      Spacer()
      if let count {
        Text("\(count)")
          .foregroundStyle(Color.primary)
          .font(.title)
          .fontDesign(.rounded)
          .bold()
      }
    }
    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
    .background(Color(.secondarySystemGroupedBackground))
    .cornerRadius(24)
  }
  
  static func completed(model: DashboardModel) -> some View {
    Self(
      model: model,
      name: "Completed",
      image: "checkmark",
      color: .green.mix(with: .gray, by: 0.5),
      count: model.stats?.completedCount
    )
  }
  static func deleted(model: DashboardModel) -> some View {
    Self(
      model: model,
      name: "Deleted",
      image: "xmark",
      color: .red.mix(with: .gray, by: 0.5),
      count: model.stats?.deletedCount
    )
  }
  static func scheduled(model: DashboardModel) -> some View {
    Self(
      model: model,
      name: "Scheduled",
      image: "calendar",
      color: .orange.mix(with: .gray, by: 0.5),
      count: model.stats?.scheduledCount
    )
  }
  static func inProgress(model: DashboardModel) -> some View {
    Self(
      model: model,
      name: "In Progress",
      image: "tray",
      color: .blue.mix(with: .gray, by: 0.5),
      count: model.stats?.inProgressCount
    )
  }
}
