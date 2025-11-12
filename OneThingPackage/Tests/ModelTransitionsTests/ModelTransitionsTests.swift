import AppModels
import Foundation
import ModelTransitions
import SQLiteData
import Testing
import TestSupport


@MainActor
struct ModelTransitionsTests {
  
  @Test(arguments: [false, true], [false, true])
  func setTransition(old: Bool, new: Bool) async throws {
    let clock = TestClock()
    await prepareTest {
      TodoListData {
        TodoData(isTransitioning: old)
        TodoData(isTransitioning: true)
        TodoData(isTransitioning: false)
      }
    } dependencies: {
      $0.continuousClock = clock
    } test: {
      let model = ModelTransitions()
      await runAction {
        model.setTransition(1, to: new)
      } assert: {
        $0.todos[0].isTransitioning = new
      }
      await runAction {
        await clock.advance(by: .seconds(2))
      } assert: {
        $0.todos[0].completeDate = new ? Date(1) : nil
        $0.todos[0].isTransitioning = false
        $0.todos[1].completeDate = Date(1)
        $0.todos[1].isTransitioning = false
      }
    }
  }
}
