import AppModels
import Dependencies
import Foundation
import ModelActions
import Sharing
import SQLiteData
import SwiftUI
import Utilities


@MainActor
@Observable
public final class AppFeatureModel {
}

public extension AppFeatureModel {
  
  func startRebalanceLoop() {
    Task(priority: .background) {
      @Dependency(\.continuousClock) var clock
      @Dependency(\.modelActions) var modelActions
      while true {
        try modelActions.purge()
        try modelActions.rebalanceTodoRanks()
        try await clock.sleep(for: .seconds(60*60*24))
      }
    }
  }
}
