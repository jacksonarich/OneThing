import AppModels
import SwiftUI

public struct TodoRowButton: View {
  let action: () -> Void
  let isCompleted: Bool
  let isDeleted: Bool
  let isTransitioning: Bool
  let subtitle: String?
  let title: String
  
  public init(
    title: String,
    completed: Bool,
    deleted: Bool,
    subtitle: String?,
    transitioning: Bool,
    action: @escaping () -> Void
  ) {
    self.action = action
    self.isCompleted = completed
    self.isDeleted = deleted
    self.isTransitioning = transitioning
    self.title = title
    self.subtitle = subtitle
  }
  
  public init(
    todo: Todo,
    subtitle: String? = nil,
    action: @escaping () -> Void
  ) {
    self.action = action
    self.isCompleted = todo.completeDate != nil
    self.isDeleted = todo.deleteDate != nil
    self.isTransitioning = todo.isTransitioning
    self.subtitle = subtitle
    self.title = todo.title
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
            .fontDesign(.rounded)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .strikethrough(isTransitioning)
          if let subtitle {
            Text(subtitle)
              .foregroundStyle(Color.secondary)
              .font(.callout)
              .fontDesign(.rounded)
              .animation(.default, value: self.subtitle)
          }
        }
        Spacer(minLength: 0)
      }
      .animation(nil, value: isTransitioning)
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
      completed: true,
      deleted: true,
      subtitle: "Subtitle",
      transitioning: false
    ) {
      print("Tapped")
    }
  }
  .listStyle(.plain)
}
