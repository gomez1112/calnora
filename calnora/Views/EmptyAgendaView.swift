import SwiftUI

struct EmptyAgendaView: View {
  var body: some View {
    VStack(spacing: 10) {
      Image(systemName: "sun.max.fill")
        .font(.title)
        .foregroundStyle(CalnoraTheme.accent)
        .accessibilityHidden(true)

      Text("Open day")
        .font(.headline)
        .foregroundStyle(CalnoraTheme.ink)

      Text("No events match this calendar filter.")
        .font(.subheadline)
        .foregroundStyle(CalnoraTheme.mutedInk)
    }
    .frame(maxWidth: .infinity)
    .padding()
    .background(Color.white.opacity(0.7), in: .rect(cornerRadius: 20))
  }
}
