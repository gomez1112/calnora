import SwiftUI

struct CalnoraPanelStyle: ViewModifier {
  var padding: CGFloat

  func body(content: Content) -> some View {
    content
      .padding(padding)
      .background(CalnoraTheme.panel.opacity(0.9), in: .rect(cornerRadius: 28))
      .overlay {
        RoundedRectangle(cornerRadius: 28)
          .stroke(Color.black.opacity(0.06), lineWidth: 1)
      }
      .shadow(color: Color.black.opacity(0.05), radius: 24, y: 12)
  }
}

extension View {
  func calnoraPanel(padding: CGFloat = 20) -> some View {
    modifier(CalnoraPanelStyle(padding: padding))
  }
}
