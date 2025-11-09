import AppModels
import Dependencies
import Foundation
import RankGeneration
import SQLiteData


extension Database {
  public func seed(_ data: AppData) throws {
    @Dependency(\.rankGeneration) var rankGeneration
    for listData in data.lists {
      // convert list to a todolist.draft
      let list = TodoList.Draft(
        name: listData.name,
        color: listData.color,
        createDate: listData.createDate,
        modifyDate: listData.modifyDate
      )
      // insert the draft and return its id
      let listID: TodoList.ID = try TodoList
        .insert { list }
        .returning(\.id)
        .fetchOne(self)!
      // loop over list's todos and insert, using the new list id
      let ranks = rankGeneration.distribute(listData.todos.count)
      for (rank, todoData) in zip(ranks, listData.todos) {
        let todo = Todo.Draft(
          listID: listID,
          rank: todoData.rank ?? rank,
          title: todoData.title,
          notes: todoData.notes,
          deadline: todoData.deadline,
          frequencyUnit: todoData.frequencyUnit,
          frequencyCount: todoData.frequencyCount,
          createDate: todoData.createDate,
          modifyDate: todoData.modifyDate,
          completeDate: todoData.completeDate,
          deleteDate: todoData.deleteDate,
          isTransitioning: todoData.isTransitioning
        )
        try Todo
          .insert { todo }
          .execute(self)
      }
    }
  }
}
