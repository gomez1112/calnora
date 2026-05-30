import Foundation
import Observation

@Observable
final class CalnoraDashboardModel {
  var selectedDate: Date
  var selectedCalendar: EventCalendar?
  var events: [CalendarEvent]

  init(
    selectedDate: Date = Date(),
    selectedCalendar: EventCalendar? = nil,
    events: [CalendarEvent] = CalnoraDashboardModel.sampleEvents(relativeTo: Date())
  ) {
    self.selectedDate = selectedDate
    self.selectedCalendar = selectedCalendar
    self.events = events
  }

  var visibleDays: [CalendarDay] {
    (-3...10).map { offset in
      let date = Calendar.current.date(byAdding: .day, value: offset, to: selectedDate) ?? selectedDate
      return CalendarDay(date: date, eventCount: events(on: date).count)
    }
  }

  var filteredEvents: [CalendarEvent] {
    events(on: selectedDate)
      .filter { event in
        selectedCalendar == nil || event.calendar == selectedCalendar
      }
      .sorted { $0.start < $1.start }
  }

  var upcomingEvents: [CalendarEvent] {
    events
      .filter { $0.start >= Calendar.current.startOfDay(for: selectedDate) }
      .sorted { $0.start < $1.start }
      .prefix(4)
      .map(\.self)
  }

  var summaries: [CalendarSummary] {
    [
      CalendarSummary(title: "Planned", value: "\(filteredEvents.count)", symbolName: "calendar.badge.clock"),
      CalendarSummary(title: "Focus", value: "\(focusHours.formatted(.number.precision(.fractionLength(1))))h", symbolName: "target"),
      CalendarSummary(title: "Open Space", value: "\(openSpacePercent)%", symbolName: "circle.dotted")
    ]
  }

  var focusHours: Double {
    filteredEvents.reduce(0) { partialResult, event in
      partialResult + event.end.timeIntervalSince(event.start) / 3600
    }
  }

  var openSpacePercent: Int {
    max(0, 100 - Int(focusHours * 12))
  }

  func select(_ day: CalendarDay) {
    selectedDate = day.date
  }

  func search() {}

  func addEvent() {}

  func events(on date: Date) -> [CalendarEvent] {
    events.filter { Calendar.current.isDate($0.start, inSameDayAs: date) }
  }

  static func sampleEvents(relativeTo date: Date) -> [CalendarEvent] {
    let calendar = Calendar.current
    let startOfDay = calendar.startOfDay(for: date)

    return [
      CalendarEvent(
        id: UUID(),
        title: "Design critique",
        subtitle: "Review onboarding flows",
        start: calendar.date(byAdding: .hour, value: 9, to: startOfDay) ?? date,
        end: calendar.date(byAdding: .minute, value: 630, to: startOfDay) ?? date,
        calendar: .studio,
        priority: .high
      ),
      CalendarEvent(
        id: UUID(),
        title: "Deep work block",
        subtitle: "Roadmap notes and scope",
        start: calendar.date(byAdding: .hour, value: 11, to: startOfDay) ?? date,
        end: calendar.date(byAdding: .hour, value: 13, to: startOfDay) ?? date,
        calendar: .strategy,
        priority: .medium
      ),
      CalendarEvent(
        id: UUID(),
        title: "Training",
        subtitle: "Intervals at the park",
        start: calendar.date(byAdding: .hour, value: 17, to: startOfDay) ?? date,
        end: calendar.date(byAdding: .minute, value: 1080, to: startOfDay) ?? date,
        calendar: .health,
        priority: .low
      ),
      CalendarEvent(
        id: UUID(),
        title: "Dinner with Maya",
        subtitle: "Bar Primi reservation",
        start: calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date,
        end: calendar.date(byAdding: .minute, value: 1620, to: startOfDay) ?? date,
        calendar: .personal,
        priority: .medium
      ),
      CalendarEvent(
        id: UUID(),
        title: "Launch review",
        subtitle: "Metrics, blockers, next moves",
        start: calendar.date(byAdding: .day, value: 2, to: startOfDay) ?? date,
        end: calendar.date(byAdding: .minute, value: 3540, to: startOfDay) ?? date,
        calendar: .strategy,
        priority: .high
      )
    ]
  }
}
