@testable import AppFeature
import Dependencies
import XCTest

@MainActor
final class AppFeatureTests: XCTestCase {
  func testPurge() async throws {
    let clock = TestClock()
    let purge1 = expectation(description: "purge action did run")
    let purge2 = expectation(description: "purge action did run")
    let purge1Fulfilled = LockIsolated(false)
    await withDependencies {
      $0.continuousClock = clock
      $0.modelActions.purge = {
        if purge1Fulfilled.value == false {
          purge1.fulfill()
          purge1Fulfilled.setValue(true)
        } else {
          purge2.fulfill()
        }
      }
      $0.modelActions.rebalanceTodoRanks = {}
    } operation: {
      let model = AppFeatureModel()
      model.startDbMaintenanceLoop()
      await fulfillment(of: [purge1], timeout: 3)
      
      await clock.advance(by: .seconds(60*60*24))
      await fulfillment(of: [purge2], timeout: 3)
    }
  }

  func testRebalance() async throws {
    let clock = TestClock()
    let rebalance1 = expectation(description: "initial rebalance")
    let rebalance2 = expectation(description: "second rebalance")
    let rebalance1Fulfilled = LockIsolated(false)
    await withDependencies {
      $0.continuousClock = clock
      $0.modelActions.purge = {}
      $0.modelActions.rebalanceTodoRanks = {
        if rebalance1Fulfilled.value == false {
          rebalance1.fulfill()
          rebalance1Fulfilled.setValue(true)
        } else {
          rebalance2.fulfill()
        }
      }
    } operation: {
      let model = AppFeatureModel()
      model.startDbMaintenanceLoop()
      await fulfillment(of: [rebalance1], timeout: 3)
      
      await clock.advance(by: .seconds(60*60*24))
      await fulfillment(of: [rebalance2], timeout: 3)
    }
  }
}
