import SwiftUI

struct CalnoraRegularDashboardView: View {
  var model: CalnoraDashboardModel

  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      CalnoraHeroView(model: model)

      HStack(alignment: .top, spacing: 24) {
        VStack(alignment: .leading, spacing: 18) {
          CalendarStripView(model: model)
          SummaryGridView(summaries: model.summaries)
          AgendaListView(events: model.filteredEvents)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)

        VStack(alignment: .leading, spacing: 18) {
          CalendarFilterView(model: model)
          MonthContextView(model: model)
          UpcomingListView(events: model.upcomingEvents)
        }
        .frame(maxWidth: 360, alignment: .topLeading)
      }
    }
    .frame(maxWidth: 1180)
  }
}
