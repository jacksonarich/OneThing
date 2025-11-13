import Foundation
import StructuredQueries


public struct TransitionAction: Codable, Hashable, QueryBindable, RawRepresentable, Sendable {
  public var rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  public static let complete = Self(rawValue: "complete")
  public static let putBack = Self(rawValue: "putBack")
  
  public static let allCases: [Self] = [
    .complete, .putBack
  ]
}
