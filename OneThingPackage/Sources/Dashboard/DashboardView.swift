import SQLiteData
import SwiftUI

import AppDatabase
import AppModels
import NewList
import Search
import Utilities


public struct DashboardView: View {
  @State private var model = DashboardModel()
  @State private var searchModel = SearchModel()
  
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
    .sheet(isPresented: $model.isCreatingList) {
      NavigationStack {
        NewListView(model: .init())
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
          model.isEditing.toggle()
        }
      }
      Button("New List", systemImage: "plus") {
        model.isCreatingList.toggle()
      }
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
            .fontDesign(.rounded)
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
  @State var model: DashboardModel
  
  var body: some View {
    ForEach(model.lists, id: \.id) { row in
      Button {
        model.listRowTapped(id: row.id)
      } label: {
        ListRowView(model: model, row: row)
      }
    }
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
    DashboardView()
  }
  .accentColor(.pink)
}
