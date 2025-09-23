import AppDatabase
import DependenciesTestSupport
import SQLiteData
import SwiftUI
import Testing


@Suite(
  .dependency(\.continuousClock, ImmediateClock()),
  .dependency(\.defaultDatabase, try appDatabase()),
  .dependency(\.uuid, .incrementing)
)
public struct BaseTestSuite {}
