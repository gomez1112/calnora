import SwiftUI

struct SummaryTileView: View {
  var summary: CalendarSummary

  var body: some View {
    HStack(spacing: 14) {
      Image(systemName: summary.symbolName)
        .font(.title3)
        .foregroundStyle(CalnoraTheme.accent)
        .frame(width: 38, height: 38)
        .background(CalnoraTheme.accent.opacity(0.12), in: .rect(cornerRadius: 14))
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 2) {
        Text(summary.value)
          .font(.title3)
          .bold()
          .foregroundStyle(CalnoraTheme.ink)

        Text(summary.title)
          .font(.caption)
          .foregroundStyle(CalnoraTheme.mutedInk)
      }

      Spacer(minLength: 0)
    }
    .calnoraPanel(padding: 16)
  }
}
