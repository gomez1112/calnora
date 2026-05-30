import SwiftUI

struct DayPillView: View {
  var day: CalendarDay
  var isSelected: Bool
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Text(day.weekdayText)
          .font(.caption)
          .foregroundStyle(isSelected ? .white.opacity(0.8) : CalnoraTheme.mutedInk)

        Text(day.dayText)
          .font(.title3)
          .bold()
          .foregroundStyle(isSelected ? .white : CalnoraTheme.ink)

        Circle()
          .fill(isSelected ? .white : CalnoraTheme.accent)
          .frame(width: day.eventCount == 0 ? 4 : 7, height: day.eventCount == 0 ? 4 : 7)
          .opacity(day.eventCount == 0 ? 0.25 : 1)
      }
      .frame(width: 70, height: 96)
      .background(isSelected ? CalnoraTheme.accent : Color.white.opacity(0.72), in: .rect(cornerRadius: 24))
      .overlay {
        RoundedRectangle(cornerRadius: 24)
          .stroke(isSelected ? CalnoraTheme.accent : Color.black.opacity(0.06), lineWidth: 1)
      }
    }
    .buttonStyle(.plain)
    .accessibilityLabel(day.date.formatted(date: .complete, time: .omitted))
  }
}
