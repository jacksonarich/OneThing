import AppModels
import Foundation
import ModelTransitions
import SQLiteData
import Testing
import TestSupport


@MainActor
struct ModelTransitionsTests {
  
  @Test(arguments: [TransitionAction.complete, nil as TransitionAction?], [nil as TransitionAction?, TransitionAction.complete])
  func setTransition(old: TransitionAction?, new: TransitionAction?) async throws {
    let clock = TestClock()
    await prepareTest {
      TodoListData {
        TodoData(transition: old)
        TodoData(transition: .complete)
        TodoData(transition: nil)
      }
    } dependencies: {
      $0.continuousClock = clock
    } test: {
      let model = ModelTransitions()
      await runAction {
        model.setTransition(1, to: new)
      } assert: {
        $0.todos[0].transition = new
      }
      await runAction {
        await clock.advance(by: .seconds(2))
      } assert: {
        $0.todos[0].completeDate = new == nil ? nil : Date(1)
        $0.todos[1].completeDate = Date(1)
        for i in 0...2 {
          $0.todos[i].transition = nil
        }
      }
    }
  }
}
