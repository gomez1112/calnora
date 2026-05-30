import SwiftUI

struct CalendarFilterView: View {
  var model: CalnoraDashboardModel

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Calendars")
        .font(.headline)
        .foregroundStyle(CalnoraTheme.ink)

      HStack {
        FilterChipView(title: "All", tint: CalnoraTheme.ink, isSelected: model.selectedCalendar == nil) {
          withAnimation(.snappy) {
            model.selectedCalendar = nil
          }
        }

        ForEach(EventCalendar.allCases) { calendar in
          FilterChipView(title: calendar.rawValue, tint: calendar.tint, isSelected: model.selectedCalendar == calendar) {
            withAnimation(.snappy) {
              model.selectedCalendar = calendar
            }
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .calnoraPanel()
  }
}
