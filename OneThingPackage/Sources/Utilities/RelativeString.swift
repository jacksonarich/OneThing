import Dependencies
import Foundation


extension Date {
  public var relativeString: String {
    @Dependency(\.calendar) var calendar
    @Dependency(\.date.now) var now
    
    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.locale = calendar.locale ?? Locale(identifier: "en_US_POSIX")
    formatter.timeZone = calendar.timeZone
    
    if calendar.isDate(self, inSameDayAs: now) {
      formatter.dateFormat = "h:mm a"
    } else if calendar.isOneDayAway(self, from: now) {
      return self > now ? "Tomorrow" : "Yesterday"
    } else if calendar.isDate(self, equalTo: now, toGranularity: .year) {
      formatter.dateFormat = "MMM d"
    } else {
      formatter.dateFormat = "yyyy"
    }
    return formatter.string(from: self)
  }
}

private extension Calendar {
  func isOneDayAway(_ target: Date, from now: Date) -> Bool {
    guard
      let tomorrow = date(byAdding: .day, value: 1, to: now),
      let yesterday = date(byAdding: .day, value: -1, to: now)
    else { return false }
    return isDate(target, equalTo: tomorrow, toGranularity: .day)
      || isDate(target, equalTo: yesterday, toGranularity: .day)
  }
}
