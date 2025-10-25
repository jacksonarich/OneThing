public struct ComputedList: Codable, Hashable, RawRepresentable, Sendable {
  public let rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

extension ComputedList: Identifiable {
  public var id: Self { self }
}
