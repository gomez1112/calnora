import SwiftUI

enum EventCalendar: String, CaseIterable, Identifiable {
  case studio = "Studio"
  case personal = "Personal"
  case strategy = "Strategy"
  case health = "Health"

  var id: String { rawValue }

  var iconName: String {
    switch self {
    case .studio:
      "paintpalette.fill"
    case .personal:
      "sparkles"
    case .strategy:
      "chart.line.uptrend.xyaxis"
    case .health:
      "heart.fill"
    }
  }

  var tint: Color {
    switch self {
    case .studio:
      CalnoraTheme.accent
    case .personal:
      CalnoraTheme.rose
    case .strategy:
      CalnoraTheme.blue
    case .health:
      CalnoraTheme.green
    }
  }
}
