import CustomDump
import Dependencies
import DependenciesTestSupport
import Foundation
import SQLiteData
import StructuredQueries
import Testing

import AppDatabase
@testable import Dashboard
import ModelActions
import AppModels
import Utilities
import TestSupport


@MainActor
struct DashboardTests {
  
  @Test(arguments: [false, true])
  func testListRowTapped(isEditing: Bool) async throws {
    await prepareTest {
      TodoListData()
    } test: {
      let model = DashboardModel(isEditing: isEditing)
      await runAction {
        model.listRowTapped(id: 1)
        #expect(model.editingListID == (isEditing ? 1 : nil))
        expectNoDifference(model.navPath, isEditing ? [] : [.listDetail(1)])
      }
    }
  }
  
  @Test
  func testListCellTapped() async throws {
    await prepareTest {
    } test: {
      let model = DashboardModel()
      await runAction {
        model.listCellTapped(list: .inProgress)
        expectNoDifference(model.navPath, [.computedListDetail(.inProgress)])
      }
    }
  }
  
  @Test
  func testListVisibilityChanged() async throws {
    await prepareTest {
      TodoListData {
        TodoData()
      }
    } test: {
      let model = DashboardModel()
      // true -> false
      model.listVisibilityChanged(list: .inProgress, to: false)
      expectNoDifference(model.hiddenLists, [.inProgress])
      // false -> false
      model.listVisibilityChanged(list: .inProgress, to: false)
      expectNoDifference(model.hiddenLists, [.inProgress])
      // false -> true
      model.listVisibilityChanged(list: .inProgress, to: true)
      expectNoDifference(model.hiddenLists, [])
      // true -> true
      model.listVisibilityChanged(list: .inProgress, to: true)
      expectNoDifference(model.hiddenLists, [])
    }
  }
}
