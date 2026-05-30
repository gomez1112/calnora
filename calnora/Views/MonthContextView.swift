import SwiftUI

struct MonthContextView: View {
  var model: CalnoraDashboardModel
  private let columns = [GridItem(.adaptive(minimum: 34), spacing: 8)]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text(model.selectedDate.formatted(.dateTime.month(.wide).year()))
        .font(.headline)
        .foregroundStyle(CalnoraTheme.ink)

      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(model.visibleDays) { day in
          MiniDayView(
            day: day,
            isSelected: Calendar.current.isDate(day.date, inSameDayAs: model.selectedDate)
          )
        }
      }
    }
    .calnoraPanel()
  }
}
