import SwiftUI

struct CalnoraCardModifier: ViewModifier {
    var cornerRadius: CGFloat = CalnoraSpacing.cardRadius
    var tint: Color?
    var isInteractive: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(CalnoraSpacing.medium)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.background.opacity(0.72))
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .stroke(.white.opacity(0.42), lineWidth: 0.8)
                    }
                    .shadow(color: .black.opacity(0.06), radius: 24, x: 0, y: 14)
            }
            .calnoraGlass(cornerRadius: cornerRadius, tint: tint, isInteractive: isInteractive)
    }
}

extension View {
    func calnoraCard(
        cornerRadius: CGFloat = CalnoraSpacing.cardRadius,
        tint: Color? = nil,
        isInteractive: Bool = false
    ) -> some View {
        modifier(CalnoraCardModifier(cornerRadius: cornerRadius, tint: tint, isInteractive: isInteractive))
    }

    @ViewBuilder
    func calnoraGlass(cornerRadius: CGFloat, tint: Color? = nil, isInteractive: Bool = false) -> some View {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            if let tint {
                if isInteractive {
                    self.glassEffect(.regular.tint(tint.opacity(0.16)).interactive(), in: .rect(cornerRadius: cornerRadius))
                } else {
                    self.glassEffect(.regular.tint(tint.opacity(0.12)), in: .rect(cornerRadius: cornerRadius))
                }
            } else if isInteractive {
                self.glassEffect(.regular.interactive(), in: .rect(cornerRadius: cornerRadius))
            } else {
                self.glassEffect(.regular, in: .rect(cornerRadius: cornerRadius))
            }
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    func calnoraScreenContent(maxWidth: CGFloat = CalnoraSpacing.screenMaxWidth) -> some View {
        self
            .frame(maxWidth: maxWidth, alignment: .top)
            .frame(maxWidth: .infinity, alignment: .top)
            .padding(.horizontal, CalnoraSpacing.medium)
            .padding(.top, CalnoraSpacing.large)
            .padding(.bottom, CalnoraSpacing.xxLarge)
    }
}
