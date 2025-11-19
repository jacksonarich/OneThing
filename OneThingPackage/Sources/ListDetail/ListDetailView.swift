import AppDatabase
import AppModels
import EditTodo
import NewTodo
import SQLiteData
import SwiftUI
import Utilities


public struct ListDetailView: View {
  @State private var model: ListDetailModel
  @State private var newTodoModel: NewTodoModel
  
  public init(listID: TodoList.ID) {
    self.model = ListDetailModel(listID: listID)
    self.newTodoModel = NewTodoModel(listID: listID)
  }
  
  public var body: some View {
    ZStack {
      List {
        ForEach(model.todos) { todo in
          TodoRowButton(
            todo: todo,
            subtitle: todo.deadline.map { "Due \($0.relativeString)" },
            isSubtitleHighlighted: todo.isOverdue,
            checkboxImage: todo.transition == nil ? .inProgressCheckbox : .completedCheckbox
          ) {
            model.todoRowTapped(todo.id, shouldTransition: todo.transition == nil)
          }
          .swipeActions {
            Button("Delete", systemImage: "xmark", role: .destructive) {
              model.deleteTodo(todo.id)
            }
          }
          .contextMenu {
            TodoRowContextMenu(
              currentListID: todo.listID,
              movableLists: model.movableLists,
              onTap: { model.todoRowTapped(todo.id, shouldTransition: todo.transition == nil) },
              onDelete: { model.deleteTodo(todo.id) },
              onEdit: { model.editTodo(todo) },
              onMove: { listID in model.moveTodo(todo.id, to: listID) }
            )
          }
        }
        .onMove(perform: model.rerankTodos)
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
      }
      .listStyle(.plain)
      if model.todos.isEmpty {
        Text("Nothing to see here")
          .foregroundStyle(Color.secondary)
      }
    }
    .sheet(isPresented: $model.isCreatingTodo, content: {
      NavigationStack {
        NewTodoView(model: newTodoModel)
      }
      .accentColor(.pink)
    })
    .sheet(item: $model.editingTodo) { todo in
      NavigationStack {
        EditTodoView(model: .init(todo))
      }
      .accentColor(.pink)
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        EditButton()
      }
      ToolbarSpacer(placement: .bottomBar)
      ToolbarItem(placement: .bottomBar) {
        Button {
          model.newTodoButtonTapped()
        } label: {
          Image(systemName: "plus")
        }
      }
    }
    .sensoryFeedback(.impact(flexibility: .solid), trigger: model.hapticID)
    .navigationTitle(model.list?.name ?? "Unknown")
    .navigationBarTitleDisplayMode(.large)
    .background(Color(.systemGroupedBackground))
  }
}


#Preview {
  let _ = prepareDependencies {
    $0.defaultDatabase = try! appDatabase(data: .previewSeed)
  }
  NavigationStack {
    ListDetailView(listID: 4)
  }
  .accentColor(.pink)
}
