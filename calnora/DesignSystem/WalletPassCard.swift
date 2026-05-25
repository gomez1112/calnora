import SwiftUI

struct WalletPassCard: View {
    var title: String
    var subtitle: String
    var systemImage: String
    var footnote: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.medium) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: CalnoraSpacing.xSmall) {
                    Text(title)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.78))
                }
                Spacer()
                Image(systemName: systemImage)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.white)
                    .accessibilityHidden(true)
            }

            Text(footnote)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.82))

            if let actionTitle, let action {
                Button(actionTitle, systemImage: "sparkles", action: action)
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(.black)
                    .accessibilityLabel(actionTitle)
            }
        }
        .padding(CalnoraSpacing.large)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(CalnoraColors.premiumGradient)
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(.white.opacity(0.12))
                .frame(width: 170, height: 170)
                .offset(x: 48, y: 60)
                .accessibilityHidden(true)
        }
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
        .shadow(color: .orange.opacity(0.2), radius: 24, x: 0, y: 12)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    WalletPassCard(
        title: "Calnora Pro",
        subtitle: "Unlimited AI nutrition coaching",
        systemImage: "sparkles",
        footnote: "Private where available. Always editable.",
        actionTitle: "Upgrade",
        action: {}
    )
    .padding()
}
