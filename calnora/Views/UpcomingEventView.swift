import SwiftUI

struct UpcomingEventView: View {
  var event: CalendarEvent

  var body: some View {
    HStack(spacing: 12) {
      Image(systemName: event.calendar.iconName)
        .font(.headline)
        .foregroundStyle(event.calendar.tint)
        .frame(width: 36, height: 36)
        .background(event.calendar.tint.opacity(0.12), in: .rect(cornerRadius: 12))
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 3) {
        Text(event.title)
          .font(.subheadline)
          .bold()
          .foregroundStyle(CalnoraTheme.ink)
          .lineLimit(1)

        Text(event.start.formatted(date: .abbreviated, time: .shortened))
          .font(.caption)
          .foregroundStyle(CalnoraTheme.mutedInk)
      }

      Spacer(minLength: 0)
    }
  }
}
