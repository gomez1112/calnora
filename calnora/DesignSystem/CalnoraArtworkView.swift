import SwiftUI

struct CalnoraArtworkView: View {
    var assetName: String
    var systemImage: String
    var tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(CalnoraColors.calmGradient)
            Circle()
                .stroke(tint.opacity(0.62), lineWidth: 18)
                .frame(width: 116, height: 116)
            Image(systemName: systemImage)
                .font(.system(size: 44, weight: .semibold))
                .foregroundStyle(.white)
        }
        .frame(height: 190)
        .accessibilityLabel(assetName.replacingOccurrences(of: "_", with: " "))
    }
}
