import AppModels
import SwiftUI


public struct TodoRowButton: View {
  let title: String
  let subtitle: String?
  let isCompleted: Bool
  let isDeleted: Bool
  let transition: TransitionAction?
  let action: () -> Void
  
  public init(
    title: String,
    subtitle: String?,
    completed: Bool,
    deleted: Bool,
    transition: TransitionAction?,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.subtitle = subtitle
    self.isCompleted = completed
    self.isDeleted = deleted
    self.transition = transition
    self.action = action
  }
  
  public init(
    todo: Todo,
    subtitle: String? = nil,
    action: @escaping () -> Void
  ) {
    self.title = todo.title
    self.subtitle = subtitle
    self.isCompleted = todo.completeDate != nil
    self.isDeleted = todo.deleteDate != nil
    self.transition = todo.transition
    self.action = action
  }
  
  private var isTransitioning: Bool {
    transition != nil
  }
  
  public var body: some View {
    Button(action: action) {
      HStack(alignment: .top) {
        Image(systemName: checkboxImage)
          .foregroundStyle(isTransitioning ? .primary : .secondary)
          .font(.title2)
          .padding(.trailing, 5)
        VStack(alignment: .leading) {
          Text(title)
            .foregroundStyle(Color.primary)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .strikethrough(isTransitioning)
          if let subtitle {
            Text(subtitle)
              .foregroundStyle(Color.secondary)
              .font(.callout)
              .animation(.default, value: self.subtitle)
          }
        }
        Spacer(minLength: 0)
      }
      .animation(nil, value: transition)
      .contentShape(Rectangle())
    }
    .buttonStyle(.borderless)
    
  }
  
  var checkboxImage: String {
    if isTransitioning {
      if isDeleted || isCompleted {
        return "circle"
      } else {
        return "checkmark.circle"
      }
    } else {
      if isDeleted {
        return "xmark.circle"
      } else {
        return isCompleted ? "checkmark.circle" : "circle"
      }
    }
  }
}


#Preview {
  List {
    TodoRowButton(
      title: "This is the todo",
      subtitle: "Subtitle",
      completed: true,
      deleted: true,
      transition: nil
    ) {
      print("Tapped")
    }
  }
  .listStyle(.plain)
}
