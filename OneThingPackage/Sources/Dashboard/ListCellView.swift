import AppModels
import SwiftUI


struct ListCellView: View {
//  @State var model: DashboardModel
//  let list: ComputedList
//  let image: String
//  let color: Color
//  let count: Int?
  private let cellModel: ListCellModel
  let list: ComputedList
  let model: DashboardModel
  
  init?(list: ComputedList, model: DashboardModel) {
    guard let cellModel = list.listCellModel(stats: model.stats) else { return nil }
    self.cellModel = cellModel
    self.list = list
    self.model = model
  }
  
  var body: some View {
    if !model.hiddenLists.contains(list) {
      Button {
        model.listCellTapped(list: list)
      } label: {
        label
      }
    }
  }
  
  var label: some View {
    HStack(alignment: .firstTextBaseline) {
      VStack(alignment: .leading, spacing: 8) {
        Image(systemName: cellModel.image)
          .font(.largeTitle)
          .symbolRenderingMode(.palette)
          .foregroundStyle(.white, cellModel.color)
        Text(list.rawValue)
          .foregroundStyle(.gray)
          .font(.headline)
          .fontDesign(.rounded)
          .bold()
          .padding(.leading, 4)
      }
      Spacer()
      if let count = cellModel.count {
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

private struct ListCellModel {
  let name: String
  let image: String
  let color: Color
  let count: Int?
}

extension ComputedList {
  fileprivate func listCellModel(stats: DashboardModel.Stats?) -> ListCellModel? {
    if self == .completed {
      return ListCellModel(
        name: rawValue,
        image: "checkmark.circle.fill",
        color: .green.mix(with: .gray, by: 0.5),
        count: stats?.completedCount
      )
    } else if self == .deleted {
      return ListCellModel(
        name: rawValue,
        image: "xmark.circle.fill",
        color: .red.mix(with: .gray, by: 0.5),
        count: stats?.deletedCount
      )
    } else if self == .scheduled {
      return ListCellModel(
        name: rawValue,
        image: "calendar.circle.fill",
        color: .orange.mix(with: .gray, by: 0.5),
        count: stats?.scheduledCount
      )
    } else if self == .inProgress {
      return ListCellModel(
        name: rawValue,
        image: "tray.circle.fill",
        color: .blue.mix(with: .gray, by: 0.5),
        count: stats?.inProgressCount
      )
    } else {
      return nil
    }
  }
}
