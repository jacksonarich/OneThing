import Dependencies
import Foundation
import Sharing
import SQLiteData
import SwiftUI

import AppModels
import ModelActions
import ModelTransitions
import Utilities


@MainActor
@Observable
public final class DashboardModel {
  
  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions
  
  @ObservationIgnored
  @Dependency(\.continuousClock)
  private var clock
  
  @ObservationIgnored
  @FetchAll
  var todos: [Todo]
  
  @ObservationIgnored
  @FetchAll(
    TodoList
      .group(by: \.id)
      .order(by: \.name)
      .leftJoin(Todo.all) { l, t in
        t.listID.eq(l.id).and(t.isInProgress)
      }
      .select { l, t in
        TodoListWithCount.Columns(
          list: l,
          count: t.count()
        )
      }
  )
  var lists
  
  @ObservationIgnored
  @FetchAll(
    TodoList
      .all
      .order(by: \.name)
  )
  var movableLists
  
  @ObservationIgnored
  @FetchOne(
    Todo.select { t in
      Stats.Columns(
        completedCount:  t.count(filter: t.isCompleted),
        deletedCount:    t.count(filter: t.isDeleted),
        scheduledCount:  t.count(filter: t.isScheduled),
        inProgressCount: t.count(filter: t.isInProgress)
      )
    },
    animation: .default
  )
  var stats
  
  @ObservationIgnored
  @Shared(.hiddenLists)
  private(set) var hiddenLists
  
  @ObservationIgnored
  @Shared(.navPath)
  private(set) var navPath
  
  var isCreatingList: Bool
  var editingListID: TodoList.ID?
  var deletingListID: TodoList.ID?
  var editMode: EditMode
  
  var isEditing: Bool {
    get { editMode.isEditing }
    set { editMode = newValue ? .active : .inactive }
  }
    
  var searchText: String {
    didSet {
      let t = $todos
      let q = todosQuery
      Task { try await t.load(q) }
    }
  }
  
  @ObservationIgnored
  private var modelTransitions = ModelTransitions()
  
  public init(
    isCreatingList: Bool         = false,
    editingListID:  TodoList.ID? = nil,
    deletingListID: TodoList.ID? = nil,
    isEditing:      Bool         = false,
    searchText:     String       = ""
  ) {
    self.isCreatingList = isCreatingList
    self.editingListID  = editingListID
    self.deletingListID = deletingListID
    self.editMode       = isEditing ? .active : .inactive
    self.searchText     = searchText
    self._todos         = FetchAll(todosQuery, animation: .default)
  }
  
  private var todosQuery: SelectOf<Todo> {
    let searchText = searchText.cleaned()
    return Todo
      .where { t in
        t.isInProgress
        .and(t.contains(searchText))
      }
      .order(by: \.title)
  }
  
  @Selection
  struct Stats {
    var completedCount: Int
    var deletedCount: Int
    var scheduledCount: Int
    var inProgressCount: Int
  }
}


extension DashboardModel {
  func toggleComplete(_ todoID: Todo.ID, complete shouldComplete: Bool) {
    modelTransitions.toggleComplete(todoID, complete: shouldComplete)
  }
  
  func deleteTodo(_ todo: Todo) {
    withErrorReporting {
      try modelActions.deleteTodo(todo.id)
    }
  }
  
  func moveTodo(id: Todo.ID, to listID: TodoList.ID) {
    withErrorReporting {
      try modelActions.moveTodo(id, listID)
    }
  }
  
  func listRowTapped(id: TodoList.ID) {
    if isEditing {
      editingListID = id
    } else {
      $navPath.withLock { navPath in
        navPath.append(.listDetail(id))
      }
    }
  }
  
  func listCellTapped(list: ComputedList) {
    $navPath.withLock { navPath in
      navPath.append(.computedListDetail(list))
    }
  }
  
  func listVisibilityChanged(list: ComputedList, to isVisible: Bool) {
    $hiddenLists.withLock { hiddenLists in
      if isVisible {
        hiddenLists.remove(list)
      } else {
        hiddenLists.insert(list)
      }
    }
  }
}
