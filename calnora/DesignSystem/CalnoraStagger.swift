import SwiftUI

struct CalnoraStaggerModifier: ViewModifier {
    var index: Int
    var hasAppeared: Bool
    var offset: CGFloat = 10

    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : offset)
            .animation(.smooth(duration: 0.5).delay(Double(index) * 0.05), value: hasAppeared)
    }
}

extension View {
    func stagger(_ index: Int, hasAppeared: Bool, offset: CGFloat = 10) -> some View {
        modifier(CalnoraStaggerModifier(index: index, hasAppeared: hasAppeared, offset: offset))
    }
}
