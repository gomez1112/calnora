import SwiftUI

struct UpcomingListView: View {
  var events: [CalendarEvent]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Upcoming")
        .font(.headline)
        .foregroundStyle(CalnoraTheme.ink)

      ForEach(events) { event in
        UpcomingEventView(event: event)
      }
    }
    .calnoraPanel()
  }
}
