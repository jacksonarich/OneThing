import Dependencies
import Foundation
import Testing
import Utilities


struct RelativeStringTests {
  
  @Test func relativeStringToUnixEpoch() {
    var calendar = Calendar(identifier: .gregorian)
    calendar.locale = Locale(identifier: "en_US_POSIX")
    calendar.timeZone = TimeZone(secondsFromGMT: 0)!
    let now = Date(timeIntervalSince1970: 0)
    withDependencies {
      $0.calendar = calendar
      $0.date.now = now
    } operation: {
      // present
      #expect(now.relativeString == "12:00 AM")
      // future
      #expect(now.add(.day, 1, calendar)?.justBefore.relativeString == "11:59 PM")
      #expect(now.add(.day, 1, calendar)?.relativeString == "Tomorrow")
      #expect(now.add(.day, 2, calendar)?.justBefore.relativeString == "Tomorrow")
      #expect(now.add(.day, 2, calendar)?.relativeString == "Jan 3")
      #expect(now.add(.year, 1, calendar)?.justBefore.relativeString == "Dec 31")
      #expect(now.add(.year, 1, calendar)?.relativeString == "1971")
      #expect(now.add(.year, 100, calendar)?.relativeString == "2070")
      // past
      #expect(now.justBefore.relativeString == "Yesterday")
      #expect(now.add(.day, -1, calendar)?.relativeString == "Yesterday")
      #expect(now.add(.day, -1, calendar)?.justBefore.relativeString == "1969")
      #expect(now.add(.year, -100, calendar)?.relativeString == "1870")
    }
  }
}


private extension Date {
  
  func add(
    _ unit: Calendar.Component,
    _ count: Int,
    _ calendar: Calendar
  ) -> Date? {
    calendar.date(byAdding: unit, value: count, to: self)
  }
  
  var justBefore: Date {
    addingTimeInterval(-1)
  }
}
