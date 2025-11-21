import SwiftUI

extension View {
  @ViewBuilder
  public func glassDynamic(
    prominent isProminent: Bool? = nil
  ) -> some View {
    if #available(iOS 26, macOS 26, *) {
      modifier(GlassDynamicModifier(prominent: isProminent))
    } else {
      self
    }
  }
}

@available(iOS 26, macOS 26, *)
public struct GlassDynamicModifier: ViewModifier {
  let isProminent: Bool?
  
  public init(prominent isProminent: Bool? = nil) {
    self.isProminent = isProminent
  }
  
  @Environment(\.isEnabled) private var isEnabled
  
  public func body(content: Content) -> some View {
    if isProminent == true || (isProminent == nil && isEnabled) {
      content
        .buttonStyle(.glassProminent)
    } else {
      content
    }
  }
}
