import SwiftUI
import Utilities

public struct SearchView: View {
  let model: SearchModel
  
  public init(model: SearchModel) {
    self.model = model
  }
  
  public var body: some View {
    ForEach(model.todos) { todo in
      TodoRowButton(
        todo: todo,
        subtitle: todo.deadline.map { "Due \($0.subtitle)" }
      ) {
        
      }
      .listRowSeparator(.hidden)
    }
  }
}
