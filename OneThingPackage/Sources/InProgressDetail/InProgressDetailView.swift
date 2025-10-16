import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


public struct InProgressDetailView: View {
  @State var model: InProgressDetailModel
  
  public init(model: InProgressDetailModel) {
    self.model = model
  }
  
  public var body: some View {
    ZStack {
      List {
        ForEach(model.todoGroups) { group in
          let listColor = Color.all[group.list.colorIndex]
          Section {
            ForEach(group.todos) { todo in
              TodoRowView(
                model: model,
                todo: todo 
              )
//              .tint(listColor)
            }
          } header: {
            Text(group.list.name) 
              .foregroundStyle(listColor)
              .font(.title2)
              .fontDesign(.rounded)
              .bold()
              .lineLimit(2)
          }
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
      .listStyle(.plain)
      if model.todoGroups.isEmpty {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
          .fontDesign(.rounded)
      }
    }
    .navigationTitle("In Progress")
    .navigationBarTitleDisplayMode(.large)
    .background(Color(.systemGroupedBackground))
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(
      lists: .preset(),
      todos: .preset()
    )
  }
  NavigationStack {
    InProgressDetailView(model: .init())
  }
  .accentColor(.pink)
}
