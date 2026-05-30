import Foundation
import SwiftUI

struct CalendarEvent: Identifiable, Equatable {
  var id: UUID
  var title: String
  var subtitle: String
  var start: Date
  var end: Date
  var calendar: EventCalendar
  var priority: EventPriority

  var timeRangeText: String {
    "\(start.formatted(date: .omitted, time: .shortened)) - \(end.formatted(date: .omitted, time: .shortened))"
  }
}
