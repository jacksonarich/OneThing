import SQLiteData
import SwiftUI

import AppDatabase
import Utilities


public struct DashboardView: View {
  @State var model: DashboardModel
  
  public init(model: DashboardModel) {
    self.model = model
  }
  
  public var body: some View {
    List {
      if model.searchText.cleaned().isEmpty {
        Section {
          ListCells(model: model)
        }
        Section {
          ListRows(model: model)
        }
      } else {
        ForEach(model.todos) { todo in
          Text(todo.title)
//          TodoRowView(
//            todo:          todo,
//            movableLists:  model.lists.map(\.list),
//            onComplete:    model.completeTodo,
//            onDelete:      model.deleteTodo,
//            onPutBack:     model.putBackTodo,
//            onMove:        model.moveTodo,
//          )
        }
      }
    }
    .scrollContentBackground(.hidden)
    .background(Color(.systemGroupedBackground))
    .searchable(text: $model.searchText)
//    .sheet(isPresented: $model.isCreatingList) {
//      NavigationStack {
//        NewListView(model: .init())
//      }
//    }
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
  @State var model: DashboardModel
  
  var body: some View {
    if model.isEditing {
      ForEach(["Completed", "Deleted", "Scheduled", "In Progress"], id: \.self) { name in
        SelectableRow(isSelected: Binding(
          get: { !model.hiddenLists.contains(name) },
          set: { model.listVisibilityChanged(name: name, to: $0) }
        )) {
          Text(name)
        }
      }
    } else {
      LazyVGrid(
        columns: (1...2).map {_ in GridItem(spacing: 16)},
        spacing: 16
      ) {
        ListCellView.completed(model: model)
        ListCellView.deleted(model: model)
        ListCellView.scheduled(model: model)
        ListCellView.inProgress(model: model)
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
    DashboardView(model: .init())
  }
}
