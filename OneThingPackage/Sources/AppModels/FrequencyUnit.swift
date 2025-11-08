import Foundation
import StructuredQueries


public struct FrequencyUnit: Codable, Hashable, QueryBindable, RawRepresentable, Sendable {
  public var rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  public static let day = FrequencyUnit(rawValue: "day")
  public static let week = FrequencyUnit(rawValue: "week")
  public static let month = FrequencyUnit(rawValue: "month")
  public static let year = FrequencyUnit(rawValue: "year")
  
  public static var allCases: [Self] {
    [.day, .week, .month, .year]
  }
}


extension FrequencyUnit {
  public var calendarComponent: Calendar.Component? {
    switch self {
    case .day: .day
    case .week: .weekOfYear
    case .month: .month
    case .year: .year
    default: nil
    }
  }
}
