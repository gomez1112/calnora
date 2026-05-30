import SwiftUI

struct AgendaListView: View {
  var events: [CalendarEvent]

  var body: some View {
    VStack(alignment: .leading, spacing: 14) {
      Text("Today")
        .font(.headline)
        .foregroundStyle(CalnoraTheme.ink)

      if events.isEmpty {
        EmptyAgendaView()
      } else {
        VStack(spacing: 12) {
          ForEach(events) { event in
            EventRowView(event: event)
          }
        }
      }
    }
    .calnoraPanel()
  }
}
