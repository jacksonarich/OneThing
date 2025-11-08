import AppDatabase
import AppModels
import Dependencies
import DependenciesTestSupport
import Foundation
@testable import InProgressDetail
import SQLiteData
import Testing

@MainActor
@Suite(
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.date.now, Date(timeIntervalSince1970: 0))
)
struct InProgressDetailTests {
}
