import AppModels
import Dependencies
import DependenciesMacros
import Foundation
import RankGeneration
import SQLiteData


/// Returns a stable connection to the local database, creating an empty database if necessary.
public func appDatabase(
  data: @autoclosure () -> AppData = AppData()
) throws -> any DatabaseWriter {
  
  // get connection
  let connection = try getDatabaseConnection()
  try migrate(connection)
  
  // seed database
#if DEBUG
  @Dependency(\.context) var context
  if context != .live {
    try connection.write { db in
      try db.seed(data())
    }
  }
#endif
  
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


func getDatabaseConnection() throws -> any DatabaseWriter {
  @Dependency(\.context) var context // magically knows if we're in a preview or not
  let connection: any DatabaseWriter
  let config = getDatabaseConfig()
  if context == .live {
    let path = URL.documentsDirectory.appending(component: "db.sqlite").path() // stored on disk
    print(path)
    connection = try DatabaseQueue(path: path, configuration: config)
  } else {
    connection = try DatabaseQueue(configuration: config) // stored in memory
  }
  return connection
}


func migrate(_ connection: DatabaseWriter) throws {
  var migrator = DatabaseMigrator()
  #if DEBUG
  migrator.eraseDatabaseOnSchemaChange = true
  #endif
  migrator.registerMigration("Create lists table") { db in
    // lists table
    try db.create(table: "todoLists") { table in
      table.autoIncrementedPrimaryKey("id")
      table.column("name", .text).notNull()
      table.column("color", .text).notNull()
      table.column("createDate", .date).notNull()
      table.column("modifyDate", .date).notNull()
    }
    // todos table
    try db.create(table: "todos") { table in
      table.autoIncrementedPrimaryKey("id")
      table.column("listID", .integer).notNull().references("todoLists")
      table.column("rank", .text).notNull()
      table.column("title", .text).notNull()
      table.column("notes", .text).notNull()
      table.column("deadline", .date)
      table.column("frequencyUnit", .text)
      table.column("frequencyCount", .integer)
      table.column("createDate", .date).notNull()
      table.column("modifyDate", .date).notNull()
      table.column("completeDate", .date)
      table.column("deleteDate", .date)
      table.column("isTransitioning", .boolean).notNull()
    }
  }
  try migrator.migrate(connection)
}

