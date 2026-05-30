import SwiftUI

struct CalnoraCompactDashboardView: View {
  var model: CalnoraDashboardModel

  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      CalnoraHeroView(model: model)
      CalendarStripView(model: model)
      SummaryGridView(summaries: model.summaries)
      CalendarFilterView(model: model)
      AgendaListView(events: model.filteredEvents)
      UpcomingListView(events: model.upcomingEvents)
    }
  }
}
