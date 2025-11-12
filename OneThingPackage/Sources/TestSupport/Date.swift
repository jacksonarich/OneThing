import Foundation


public extension Date {
  init(_ timeInterval: TimeInterval) {
    self.init(timeIntervalSince1970: timeInterval)
  }
}
