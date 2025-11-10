import AppDatabase
import AppModels
import NewList
import Search
import SQLiteData
import SwiftUI
import Utilities


public struct DashboardView: View {
  @State private var model = DashboardModel()
  @State private var searchModel = SearchModel()
  @State private var newListModel = NewListModel()
  
  public init() {}
  
  public var body: some View {
    List {
      if searchModel.searchText.cleaned().isEmpty {
        Section {
          ListCells(model: model)
        }
        Section {
          ListRows(model: model)
        }
      } else {
        SearchView(model: searchModel)
      }
    }
    .searchable(text: $searchModel.searchText)
    .sheet(isPresented: $model.isCreatingList) {
      NavigationStack {
        NewListView(model: newListModel)
      }
    }
//    .sheet(item: $model.editingListID) { listID in
//      NavigationStack {
//        EditListView(model: .init(listID: listID))
//      }
//    }
    .toolbar {
      Button(model.isEditing ? "Done" : "Edit") {
        withAnimation {
          model.editButtonTapped()
        }
      }
      Button("New List", systemImage: "plus") {
        model.createListButtonTapped()
      }
      
#if DEBUG
      Button("Seed") {
        @Dependency(\.defaultDatabase) var connection
        withErrorReporting {
          try connection.write { db in
            try Todo.delete().execute(db)
            try TodoList.delete().execute(db)
            try db.seed(.previewSeed)
          }
        }
      }
#endif
    }
    .environment(\.editMode, $model.editMode)
  }
}


struct ListCells: View {
  let model: DashboardModel
  
  var body: some View {
    if model.isEditing {
      ForEach(ComputedList.all) { computedList in
        SelectableRow(
          isSelected: Binding(
            get: { !model.hiddenLists.contains(computedList) },
            set: { model.listVisibilityChanged(list: computedList, to: $0) }
          )
        ) {
          Text(computedList.rawValue)
        }
      }
    } else {
      LazyVGrid(
        columns: (1...2).map {_ in GridItem(spacing: 8) },
        spacing: 8
      ) {
        ForEach(ComputedList.all) { list in
          if let cellView = ListCellView(list: list, model: model) {
            cellView
          }
        }
      }
      .buttonStyle(.plain)
      .listRowBackground(Color.clear)
      .padding(.horizontal, -20)
    }
  }
}


fileprivate struct ListRows: View {
  let model: DashboardModel
  
  var body: some View {
    ForEach(model.lists, id: \.id) { row in
      Button {
        model.listRowTapped(id: row.id)
      } label: {
        ListRowView(
          name: row.list.name,
          color: row.list.color.swiftUIColor ?? .gray,
          count: row.count
        )
      }
    }
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  NavigationStack {
    DashboardView()
  }
  .accentColor(.pink)
}
