import SwiftUI

struct CalendarStripView: View {
  var model: CalnoraDashboardModel

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Next Days")
        .font(.headline)
        .foregroundStyle(CalnoraTheme.ink)

      ScrollView(.horizontal) {
        HStack(spacing: 10) {
          ForEach(model.visibleDays) { day in
            DayPillView(
              day: day,
              isSelected: Calendar.current.isDate(day.date, inSameDayAs: model.selectedDate)
            ) {
              withAnimation(.snappy) {
                model.select(day)
              }
            }
          }
        }
        .padding(.vertical, 2)
      }
      .scrollIndicators(.hidden)
    }
    .calnoraPanel()
  }
}
