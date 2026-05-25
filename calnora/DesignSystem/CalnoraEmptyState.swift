import SwiftUI

struct CalnoraEmptyState: View {
    var title: String
    var message: String
    var systemImage: String
    var tint: Color

    var body: some View {
        VStack(spacing: CalnoraSpacing.medium) {
            Image(systemName: systemImage)
                .font(.system(size: 36, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 72, height: 72)
                .background(tint.opacity(0.14), in: .circle)
                .accessibilityHidden(true)
            VStack(spacing: CalnoraSpacing.xSmall) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .calnoraCard(tint: tint)
        .accessibilityElement(children: .combine)
    }
}
