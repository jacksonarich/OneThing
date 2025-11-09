import AppModels
import Dependencies
import Foundation
import ModelActions
import ModelTransitions
import SQLiteData
import SwiftUI
import Utilities


@MainActor
@Observable
public final class SearchModel {
  
  @ObservationIgnored
  @Dependency(\.modelActions)
  private var modelActions
  
  @ObservationIgnored
  @FetchAll(
    TodoList
      .all
      .order(by: \.name)
  )
  var movableLists

  @ObservationIgnored
  @FetchAll(
    SearchModel.searchResultQuery(""),
    animation: .default
  )
  var todos: [Todo]

  @ObservationIgnored
  private var modelTransitions = ModelTransitions()

  public var searchText: String {
    didSet {
      let t = $todos
      let q = Self.searchResultQuery(searchText)
      Task { try await t.load(q, animation: .default) }
    }
  }

  public init(text: String = "") {
    self.searchText = text
    self._todos = FetchAll(SearchModel.searchResultQuery(text), animation: .default)
  }
}


extension SearchModel {
  private static func searchResultQuery(_ text: String) -> SelectOf<Todo> {
    Todo
      .where { t in
        t.isInProgress
          .and(t.contains(text.cleaned()))
      }
      .order(by: \.title)
  }
}


public extension SearchModel {
  
  func todoRowTapped(_ todoID: Todo.ID, isTransitioning: Bool) {
    modelTransitions.setTransition(todoID, to: isTransitioning == false)
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
}

