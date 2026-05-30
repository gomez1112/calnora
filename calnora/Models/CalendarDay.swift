import Foundation

struct CalendarDay: Identifiable, Equatable {
  var id: Date { date }
  var date: Date
  var eventCount: Int

  var weekdayText: String {
    date.formatted(.dateTime.weekday(.narrow))
  }

  var dayText: String {
    date.formatted(.dateTime.day())
  }
}
