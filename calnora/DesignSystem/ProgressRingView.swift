import SwiftUI

struct ProgressRingView: View {
    var progress: Double
    var tint: Color
    var lineWidth: CGFloat = 14

    var body: some View {
        ZStack {
            Circle()
                .stroke(tint.opacity(0.14), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    tint.gradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    ProgressRingView(progress: 0.72, tint: CalnoraColors.calories)
        .frame(width: 120, height: 120)
        .padding()
}
