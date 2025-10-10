// Behaviorless structures for use by the entire app.


import Sharing
import SQLiteData
import SwiftUI


public enum NavigationDestination: Codable, Hashable, Sendable {
  case dashboard
  case listDetail(TodoList.ID)
  case computedListDetail(String)
  case empty
}


@Table
public struct Todo: Identifiable, Equatable, Sendable {
  public let id:                 ID
  public let title:              String
  public let notes:              String
  public let deadline:           Date?
  public let frequencyUnitIndex: Int?
  public let frequencyCount:     Int?
  public let createDate:         Date
  public let modifyDate:         Date
  public let completeDate:       Date?
  public let deleteDate:         Date?
  public let order:              String
  public let listID:             TodoList.ID
  
  public typealias ID = Int
  
  public init(
    id:                 ID,
    title:              String,
    notes:              String,
    deadline:           Date?,
    frequencyUnitIndex: Int?,
    frequencyCount:     Int?,
    createDate:         Date,
    modifyDate:         Date,
    completeDate:       Date?,
    deleteDate:         Date?,
    order:              String,
    listID:             TodoList.ID
  ) {
    self.id                 = id
    self.title              = title
    self.notes              = notes
    self.deadline           = deadline
    self.frequencyUnitIndex = frequencyUnitIndex
    self.frequencyCount     = frequencyCount
    self.createDate         = createDate
    self.modifyDate         = modifyDate
    self.completeDate       = completeDate
    self.deleteDate         = deleteDate
    self.order              = order
    self.listID             = listID
  }
}


@Table
public struct TodoList: Identifiable, Equatable, Sendable {
  public let id:         ID
  public let name:       String
  public let colorIndex: Int
  public let createDate: Date
  public let modifyDate: Date
  
  public typealias ID = Int
  
  public init(
    id:         ID,
    name:       String,
    colorIndex: Int,
    createDate: Date,
    modifyDate: Date
  ) {
    self.id         = id
    self.name       = name
    self.colorIndex = colorIndex
    self.createDate = createDate
    self.modifyDate = modifyDate
  }
}


extension Todo.Draft: Equatable, Sendable {}
extension TodoList.Draft: Equatable, Sendable {}


@Selection
public struct TodoListWithCount: Equatable, Identifiable, Sendable {
  public var list: TodoList
  public var count: Int
  public var id: Int { list.id }
}


public extension Calendar.Component {
  /// Corresponds to `Todo.frequencyUnitIndex`.
  static let all: [Self] = [
    .day,
    .weekOfYear,
    .month,
    .year
  ]
}


public extension Color {
  /// Corresponds to `TodoList.colorIndex`.
  static let all: [Self] = [
    .red,
    .orange,
    .yellow,
    .green,
    .cyan,
    .blue,
    .indigo,
    .pink,
    .purple,
    .brown
  ]
}


extension SharedKey where Self == InMemoryKey<[NavigationDestination]>.Default {
  public static var navPath: Self {
    Self[.inMemory("navPath"), default: []]
  }
}

extension SharedKey where Self == AppStorageKey<Set<String>>.Default {
  public static var hiddenLists: Self {
    Self[.appStorage("hiddenLists"), default: []]
  }
}
