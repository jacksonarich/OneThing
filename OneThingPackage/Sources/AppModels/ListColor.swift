import StructuredQueries
import SwiftUI

public struct ListColor: Codable, Equatable, Hashable, QueryBindable, RawRepresentable, Sendable {
  public var rawValue: String
  
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
  
  public static let red = ListColor(rawValue: "red")
  public static let orange = ListColor(rawValue: "orange")
  public static let yellow = ListColor(rawValue: "yellow")
  public static let green = ListColor(rawValue: "green")
  public static let cyan = ListColor(rawValue: "cyan")
  public static let blue = ListColor(rawValue: "blue")
  public static let indigo = ListColor(rawValue: "indigo")
  public static let pink = ListColor(rawValue: "pink")
  public static let purple = ListColor(rawValue: "purple")
  public static let brown = ListColor(rawValue: "brown")
  
  public static let all: [Self] = [
    .red, .orange, .yellow, .green, .cyan, .blue, .indigo, .pink, .purple, .brown
  ]
}

extension ListColor {
  public var swiftUIColor: Color? {
    switch self {
    case .red: return .red
    case .orange: return .orange
    case .yellow: return .yellow
    case .green: return .green
    case .cyan: return .cyan
    case .blue: return .blue
    case .indigo: return .indigo
    case .pink: return .pink
    case .purple: return .purple
    case .brown: return .brown
    default: return nil
    }
  }
}
