import SwiftUI

struct MiniDayView: View {
  var day: CalendarDay
  var isSelected: Bool

  var body: some View {
    Text(day.dayText)
      .font(.caption)
      .bold()
      .foregroundStyle(isSelected ? .white : CalnoraTheme.ink)
      .frame(width: 34, height: 34)
      .background(isSelected ? CalnoraTheme.accent : Color.white.opacity(0.68), in: .rect(cornerRadius: 10))
      .overlay(alignment: .bottom) {
        Circle()
          .fill(isSelected ? .white : CalnoraTheme.accent)
          .frame(width: 4, height: 4)
          .opacity(day.eventCount > 0 ? 1 : 0)
          .padding(.bottom, 4)
      }
  }
}
