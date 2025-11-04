import Foundation
import StructuredQueries

public struct FrequencyUnit: Codable, Equatable, Hashable, QueryBindable, RawRepresentable, Sendable {
  public var rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  public static let day = FrequencyUnit(rawValue: "Day")
  public static let week = FrequencyUnit(rawValue: "Week")
  public static let month = FrequencyUnit(rawValue: "Month")
  public static let year = FrequencyUnit(rawValue: "Year")
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
