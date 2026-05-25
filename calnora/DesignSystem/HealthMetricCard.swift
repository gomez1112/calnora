import SwiftUI

struct HealthMetricCard: View {
    var title: String
    var value: Double
    var target: Double?
    var unit: String
    var symbolName: String
    var tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: CalnoraSpacing.small) {
            HStack(spacing: CalnoraSpacing.small) {
                Image(systemName: symbolName)
                    .font(.headline)
                    .foregroundStyle(tint)
                    .frame(width: 28, height: 28)
                    .background(tint.opacity(0.14), in: .circle)
                    .accessibilityHidden(true)

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value, format: .number.precision(.fractionLength(0)))
                    .font(CalnoraTypography.metric)
                    .monospacedDigit()
                Text(unit)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let target {
                ProgressView(value: min(max(value / max(target, 1), 0), 1))
                    .tint(tint)
                    .accessibilityLabel("\(title) progress")
                    .accessibilityValue("\(Int(value)) of \(Int(target)) \(unit)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .calnoraCard(cornerRadius: CalnoraSpacing.tileRadius, tint: tint)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    HealthMetricCard(
        title: "Protein",
        value: 82,
        target: 130,
        unit: "g",
        symbolName: "bolt.fill",
        tint: CalnoraColors.protein
    )
    .padding()
}
