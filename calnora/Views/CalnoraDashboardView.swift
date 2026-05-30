import SwiftUI

struct CalnoraDashboardView: View {
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  var model: CalnoraDashboardModel

  var body: some View {
    Group {
      if horizontalSizeClass == .regular {
        CalnoraRegularDashboardView(model: model)
      } else {
        CalnoraCompactDashboardView(model: model)
      }
    }
    .padding()
  }
}
