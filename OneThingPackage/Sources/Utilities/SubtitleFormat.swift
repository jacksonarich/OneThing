import Foundation

extension Date {
  public var subtitle: String {
    formatted(.dateTime.month(.abbreviated).day())
  }
}
