import SwiftUI

struct SummaryGridView: View {
  var summaries: [CalendarSummary]
  private let columns = [GridItem(.adaptive(minimum: 150), spacing: 12)]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 12) {
      ForEach(summaries) { summary in
        SummaryTileView(summary: summary)
      }
    }
  }
}
