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


extension Frequency {
  public var localizedString: String {
    if count == 1 {
      return "every \(unit.rawValue)"
    }
    let attributed = AttributedString(
      localized: "every ^[\(count) \(unit.rawValue)](inflect: true)"
    )
    return String(attributed.characters)
  }
}


extension Frequency {
  public init?(
    selection: FrequencySelection,
    custom: Frequency
  ) {
    switch selection {
    case .never:
      return nil
    case .daily:
      self.init(unit: .day)
    case .weekly:
      self.init(unit: .week)
    case .monthly:
      self.init(unit: .month)
    case .yearly:
      self.init(unit: .year)
    case .custom:
      self = custom
    }
  }
}
