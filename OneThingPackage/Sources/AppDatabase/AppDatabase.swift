// Exports the `appDatabase` function.


import Foundation
import SQLiteData

import Schema


/// Returns a stable connection to the local database, creating an empty database if necessary.
public func appDatabase(
  lists:   [TodoList.Draft] = [],
  todos:   [Todo.Draft]     = [],
  persist: Bool?            = nil
) throws -> any DatabaseWriter {
  // get connection
  let connection = try getDatabaseConnection(persist: persist)
  try migrate(connection)
  // seed database
  if !lists.isEmpty {
    try connection.write { db in
      try TodoList.Draft
        .insert { lists }
        .execute(db)
    }
  }
  if !todos.isEmpty {
    try connection.write { db in
      try Todo.Draft
        .insert { todos }
        .execute(db)
    }
  }
  // return
  return connection
}


func getDatabaseConfig() -> Configuration {
  let config = Configuration()
//#if DEBUG
//  config.prepareDatabase { db in
//    db.trace(options: .profile) {
//      print("\($0.expandedDescription)")
//    }
//  }
//#endif
  return config
}


func getDatabaseConnection(
  persist: Bool? = nil
) throws -> any DatabaseWriter {
  @Dependency(\.context) var context // magically knows if we're in a preview or not
  let connection: any DatabaseWriter
  let config = getDatabaseConfig()
  if persist ?? (context == .live) {
    let path = URL.documentsDirectory.appending(component: "db.sqlite").path() // stored on disk
    connection = try DatabaseQueue(path: path, configuration: config)
  } else {
    connection = try DatabaseQueue(configuration: config) // stored in memory
  }
  return connection
}


func migrate(_ connection: DatabaseWriter) throws {
  var migrator = DatabaseMigrator()
  migrator.registerMigration("Create lists table") { db in
    // lists table
    try db.create(table: "todoLists") { table in
      table.autoIncrementedPrimaryKey("id")
      table.column("name", .text).notNull()
      table.column("colorIndex", .integer).notNull()
      table.column("createDate", .date).notNull()
      table.column("modifyDate", .date).notNull()
    }
    // todos table
    try db.create(table: "todos") { table in
      table.autoIncrementedPrimaryKey("id")
      table.column("title", .text).notNull()
      table.column("notes", .text).notNull()
      table.column("deadline", .date)
      table.column("frequencyUnitIndex", .integer)
      table.column("frequencyCount", .integer)
      table.column("createDate", .date).notNull()
      table.column("modifyDate", .date).notNull()
      table.column("completeDate", .date)
      table.column("deleteDate", .date)
      table.column("order", .text).notNull() // How does this work?
      table.column("listID", .integer).notNull().references("todoLists")
    }
  }
  try migrator.migrate(connection)
}
