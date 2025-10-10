import Dependencies
import Foundation
import Sharing
import SQLiteData
import SwiftUI

import ModelActions
import Schema
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
        l.id.eq(t.listID).and(t.isInProgress)
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
  
  private(set) var transitionTask: Task<Void, Never>? = nil
  
  private(set) var transitioningTodoIDs: Set<Todo.ID> = []
  
  private(set) var highlightedTodoIDs: Set<Todo.ID> = []
    
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
        (t.isInProgress
        .and(t.contains(searchText)))
        .or(transitioningTodoIDs.contains(t.id))
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
  
  func completeTodo(id: Todo.ID) {
    _completeTodoPhase1(id: id)
    Task { await _completeTodoPhase2(id: id) }
    transitionTask = Task { await _completeTodoPhase3(id: id) }
  }
  func _completeTodoPhase1(id: Todo.ID) {
    transitionTask?.cancel()
    transitioningTodoIDs.insert(id)
    highlightedTodoIDs.insert(id)
  }
  func _completeTodoPhase2(id: Todo.ID) async {
    await withErrorReporting {
      try await $todos.load(todosQuery)
      try modelActions.completeTodo(id)
    }
  }
  func _completeTodoPhase3(id: Todo.ID) async {
    do {
      try await clock.sleep(for: .seconds(2))
      transitioningTodoIDs.removeAll()
      try await $todos.load(todosQuery, animation: .default)
      highlightedTodoIDs.removeAll()
    } catch is CancellationError {
    } catch {
      withErrorReporting { throw error }
    }
  }
  
  func deleteTodo(id: Todo.ID) {
    withErrorReporting {
      try modelActions.deleteTodo(id)
    }
  }
  
  func putBackTodo(id: Todo.ID) {
    _putBackTodoPhase1(id: id)
    Task { await _putBackTodoPhase2(id: id) }
    transitionTask = Task { await _putBackTodoPhase3(id: id) }
  }
  func _putBackTodoPhase1(id: Todo.ID) {
    transitionTask?.cancel()
    transitioningTodoIDs.remove(id)
    highlightedTodoIDs.remove(id)
  }
  func _putBackTodoPhase2(id: Todo.ID) async {
    await withErrorReporting {
      try modelActions.putBackTodo(id)
      try await $todos.load()
    }
  }
  func _putBackTodoPhase3(id: Todo.ID) async {
    do {
      try await clock.sleep(for: .seconds(2))
      transitioningTodoIDs.removeAll()
      try await $todos.load(todosQuery, animation: .default)
      highlightedTodoIDs.removeAll()
    } catch is CancellationError {
    } catch {
      withErrorReporting { throw error }
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
  
  func listCellTapped(name: String) {
    $navPath.withLock { navPath in
      navPath.append(.computedListDetail(name))
    }
  }
  
  func listVisibilityChanged(name: String, to isVisible: Bool) {
    $hiddenLists.withLock { hiddenLists in
      if isVisible {
        hiddenLists.remove(name)
      } else {
        hiddenLists.insert(name)
      }
    }
  }
}
