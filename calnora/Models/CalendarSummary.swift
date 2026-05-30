struct CalendarSummary: Identifiable, Equatable {
  var id: String { title }
  var title: String
  var value: String
  var symbolName: String
}
