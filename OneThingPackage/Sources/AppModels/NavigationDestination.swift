import Sharing

public enum NavigationDestination: Codable, Hashable, Sendable {
  case listDetail(TodoList.ID)
  case computedListDetail(ComputedList)
  case empty
}

extension SharedKey where Self == InMemoryKey<[NavigationDestination]>.Default {
  public static var navPath: Self {
    Self[.inMemory("navPath"), default: []]
  }
}
