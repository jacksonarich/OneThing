import SwiftUI

public struct CustomEditButton: View {
  let action: () -> Void
  let title: String
  
  public init(_ title: some StringProtocol, action: @escaping () -> Void) {
    self.action = action
    self.title = String(title)
  }
  
  public init(action: @escaping () -> Void) {
    self.action = action
    self.title = "Edit"
  }
  
  public var body: some View {
    if #available(iOS 26, *) {
      EditButton26(action: action, title: title)
    } else {
      EditButton18(action: action, title: title)
    }
  }
}

private struct EditButton18: View {
  let action: () -> Void
  let title: String
  
  @Environment(\.editMode) var editMode
  
  var body: some View {
    Button(action: action) {
      Text(isEditing ? "Done" : title)
    }
  }
  
  private var isEditing: Bool {
    editMode?.wrappedValue.isEditing == true
  }
}

@available(iOS 26, *)
private struct EditButton26: View {
  let action: () -> Void
  let title: String
  
  @Environment(\.editMode) var editMode
  
  var body: some View {
    Button(action: action) {
      if isEditing {
        Image(systemName: "checkmark")
      } else {
        Text(title)
      }
    }
    .glassDynamic(prominent: isEditing)
  }
  
  private var isEditing: Bool {
    editMode?.wrappedValue.isEditing == true
  }
}

#Preview("Edit Button") {
  NavigationStack {
    List {}
      .toolbar {
        if #available(iOS 26, *) {
          ToolbarItem(placement: .primaryAction) {
            CustomEditButton {
              print("Tap")
            }
            .disabled(false)
            .environment(\.editMode, .constant(.active))
          }
        }
      }
  }
}
