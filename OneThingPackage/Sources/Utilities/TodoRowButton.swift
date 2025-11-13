import AppModels
import SwiftUI


public struct TodoRowButton: View {
  let title: String
  let subtitle: String?
  let isSubtitleHighlighted: Bool
  let checkboxImage: String
  let transition: TransitionAction?
  let action: () -> Void
  
  public init(
    title: String,
    subtitle: String?,
    isSubtitleHighlighted: Bool,
    checkboxImage: String,
    transition: TransitionAction?,
    action: @escaping () -> Void
  ) {
    self.title = title
    self.subtitle = subtitle
    self.isSubtitleHighlighted = isSubtitleHighlighted
    self.checkboxImage = checkboxImage
    self.transition = transition
    self.action = action
  }
  
  public init(
    todo: Todo,
    subtitle: String? = nil,
    isSubtitleHighlighted: Bool = false,
    checkboxImage: String,
    action: @escaping () -> Void
  ) {
    self.title = todo.title
    self.subtitle = subtitle
    self.isSubtitleHighlighted = isSubtitleHighlighted
    self.checkboxImage = checkboxImage
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
              .foregroundStyle(isSubtitleHighlighted ? Color.accentColor : Color.secondary)
              .font(.callout)
              .bold(isSubtitleHighlighted)
              .animation(.default, value: self.subtitle)
              .animation(.default, value: self.isSubtitleHighlighted)
          }
        }
        Spacer(minLength: 0)
      }
      .animation(nil, value: transition)
      .contentShape(Rectangle())
    }
    .buttonStyle(.borderless)
  }
}


#Preview {
  List {
    TodoRowButton(
      title: "This is the todo",
      subtitle: "Subtitle",
      isSubtitleHighlighted: false,
      checkboxImage: "circle",
      transition: nil
    ) {
      print("Tapped")
    }
  }
  .listStyle(.plain)
  .accentColor(.pink)
}
