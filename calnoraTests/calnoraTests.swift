import Foundation
import Testing
@testable import calnora

struct CalnoraDashboardModelTests {
  @Test func filtersEventsForSelectedCalendar() throws {
    let date = try Date("2026-05-30T09:00:00Z", strategy: .iso8601)
    let model = CalnoraDashboardModel(
      selectedDate: date,
      selectedCalendar: .strategy,
      events: [
        CalendarEvent(
          id: UUID(),
          title: "Planning",
          subtitle: "Roadmap",
          start: date,
          end: date.addingTimeInterval(3600),
          calendar: .strategy,
          priority: .high
        ),
        CalendarEvent(
          id: UUID(),
          title: "Run",
          subtitle: "Track",
          start: date,
          end: date.addingTimeInterval(1800),
          calendar: .health,
          priority: .low
        )
      ]
    )

    #expect(model.filteredEvents.map(\.title) == ["Planning"])
  }

  @Test func calculatesFocusHoursFromVisibleEvents() throws {
    let date = try Date("2026-05-30T09:00:00Z", strategy: .iso8601)
    let model = CalnoraDashboardModel(
      selectedDate: date,
      events: [
        CalendarEvent(
          id: UUID(),
          title: "Build",
          subtitle: "Prototype",
          start: date,
          end: date.addingTimeInterval(5400),
          calendar: .studio,
          priority: .medium
        )
      ]
    )

    #expect(model.focusHours == 1.5)
  }
}
