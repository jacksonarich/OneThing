// Behaviorless structures for use by the entire app.


import Sharing
import SQLiteData
import SwiftUI


public extension Calendar.Component {
  /// Corresponds to `Todo.frequencyUnitIndex`.
  static let all: [Self] = [
    .day,
    .weekOfYear,
    .month,
    .year
  ]
}


public extension Color {
  /// Corresponds to `TodoList.colorIndex`.
  static let all: [Self] = [
    .red,
    .orange,
    .yellow,
    .green,
    .cyan,
    .blue,
    .indigo,
    .pink,
    .purple,
    .brown
  ]
}

