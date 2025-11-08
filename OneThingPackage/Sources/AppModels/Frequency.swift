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
//    let formatter = DateComponentsFormatter()
//    formatter.allowedUnits = [.day, .weekOfMonth, .month, .year]
//    formatter.collapsesLargestUnit = true
//    formatter.unitsStyle = .full
//    formatter.maximumUnitCount = 1
//    
//    guard
//      let components = unit.dateComponents(count),
//      var repeatString = formatter.string(from: components)
//    else { return nil }
//    if count == 1 {
//      // If you ever support another language, get this string from your localized strings file
//      let prefix = "one "
//      let unitString = repeatString.dropFirst(prefix.count)
//      repeatString = String(unitString)
//    }
//    return "every \(repeatString)"
  }
}
