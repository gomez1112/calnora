import SwiftUI

struct ContentView: View {
  @State private var model = CalnoraDashboardModel()

  var body: some View {
    NavigationStack {
      ScrollView {
        CalnoraDashboardView(model: model)
          .frame(maxWidth: .infinity)
      }
      .background(CalnoraTheme.pageBackground)
      .navigationTitle("Calnora")
      .toolbar {
        ToolbarItemGroup(placement: .topBarTrailing) {
          Button("Search", systemImage: "magnifyingglass", action: model.search)
          Button("Add Event", systemImage: "plus", action: model.addEvent)
        }
      }
    }
    .tint(CalnoraTheme.accent)
  }
}
