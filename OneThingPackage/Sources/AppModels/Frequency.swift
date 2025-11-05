import Foundation
import StructuredQueries

@Selection
public struct Frequency: Codable, Hashable, Sendable {
  public var unit: FrequencyUnit
  public var count: Int
  
  public init(
    unit: FrequencyUnit,
    count: Int = 1
  ) {
    self.unit = unit
    self.count = count
  }
}
