import SwiftUI

struct EventRowView: View {
  var event: CalendarEvent

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      VStack(spacing: 4) {
        Circle()
          .fill(event.calendar.tint)
          .frame(width: 11, height: 11)

        Rectangle()
          .fill(event.calendar.tint.opacity(0.22))
          .frame(width: 2)
      }
      .frame(height: 72)
      .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 6) {
        HStack {
          Label(event.calendar.rawValue, systemImage: event.calendar.iconName)
            .font(.caption)
            .foregroundStyle(event.calendar.tint)
            .lineLimit(1)

          Spacer(minLength: 8)

          Text(event.priority.rawValue)
            .font(.caption)
            .foregroundStyle(CalnoraTheme.mutedInk)
        }

        Text(event.title)
          .font(.headline)
          .foregroundStyle(CalnoraTheme.ink)
          .fixedSize(horizontal: false, vertical: true)

        Text("\(event.timeRangeText) - \(event.subtitle)")
          .font(.subheadline)
          .foregroundStyle(CalnoraTheme.mutedInk)
          .fixedSize(horizontal: false, vertical: true)
      }
    }
    .padding()
    .background(Color.white.opacity(0.72), in: .rect(cornerRadius: 20))
  }
}
