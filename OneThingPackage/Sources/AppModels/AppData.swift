import Dependencies
import Foundation


public struct AppData {
  public var lists: [TodoListData]
  
  public init(
    @TodoListBuilder lists: () -> [TodoListData] = {[]}
  ) {
    self.lists = lists()
  }
}

public struct TodoListData: Sendable {
  public var name: String = ""
  public var color: ListColor = .red
  public var createDate: Date
  public var modifyDate: Date
  public var todos: [TodoData]
  
  public init(
    name: String,
    color: ListColor,
    createDate: Date,
    modifyDate: Date,
    todos: [TodoData]
  ) {
    self.name = name
    self.color = color
    self.createDate = createDate
    self.modifyDate = modifyDate
    self.todos = todos
  }
  
  public init(
    name: String = "Grocery",
    color: ListColor = .red,
    createDate: Date? = nil,
    modifyDate: Date? = nil,
    @TodoBuilder todos: () -> [TodoData] = {[]}
  ) {
    self.name = name
    self.color = color
    self.createDate = createDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    self.modifyDate = modifyDate ?? createDate ?? {
      @Dependency(\.date) var date
      return date.now
    }()
    self.todos = todos()
  }
}


public struct TodoData: Sendable {
  public var title: String
  public var notes: String = ""
  public var deadline: Date? = nil
  public var frequencyUnit: FrequencyUnit? = nil
  public var frequencyCount: Int? = nil
  public var createDate: Date? = nil
  public var modifyDate: Date? = nil
  public var completeDate: Date? = nil
  public var deleteDate: Date? = nil
  public var rank: Rank? = nil
  public var isTransitioning: Bool = false
  
  public init(
    title: String,
    notes: String = "",
    deadline: Date? = nil,
    frequencyUnit: FrequencyUnit? = nil,
    frequencyCount: Int? = nil,
    createDate: Date? = nil,
    modifyDate: Date? = nil,
    completeDate: Date? = nil,
    deleteDate: Date? = nil,
    rank: Rank? = nil,
    isTransitioning: Bool = false
  ) {
    self.title = title
    self.notes = notes
    self.deadline = deadline
    self.frequencyUnit = frequencyUnit
    self.frequencyCount = frequencyCount
    self.createDate = createDate
    self.modifyDate = modifyDate
    self.completeDate = completeDate
    self.deleteDate = deleteDate
    self.rank = rank
    self.isTransitioning = isTransitioning
  }
}


@resultBuilder
public struct TodoBuilder {
  public static func buildBlock(_ components: TodoData...) -> [TodoData] {
    components
  }
}

@resultBuilder
public struct TodoListBuilder {
  public static func buildBlock(_ components: TodoListData...) -> [TodoListData] {
    components
  }
}
