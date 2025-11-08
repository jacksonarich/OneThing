import SwiftUI


public extension String {
  
  static let loremIpsum: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."

  func trimmed() -> String {
    self.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  func cleaned() -> String {
    self.trimmed().lowercased()
  }
}


public extension Optional<Binding<EditMode>> {
  
  var isEditing: Bool {
    self?.wrappedValue.isEditing == true
  }
}


// necessary for .sheet(item: $model.editedListID)
extension Int: @retroactive Identifiable {
  
   public var id: Int { self }
}
