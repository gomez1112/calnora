import SwiftUI

struct CalnoraHeroView: View {
  var model: CalnoraDashboardModel

  var body: some View {
    VStack(alignment: .leading, spacing: 18) {
      HStack(alignment: .top) {
        VStack(alignment: .leading, spacing: 8) {
          Text(model.selectedDate.formatted(date: .complete, time: .omitted))
            .font(.subheadline)
            .foregroundStyle(CalnoraTheme.mutedInk)

          Text("Shape the day before it shapes you.")
            .font(.largeTitle)
            .bold()
            .foregroundStyle(CalnoraTheme.ink)
            .fixedSize(horizontal: false, vertical: true)
        }

        Spacer(minLength: 16)

        Image(systemName: "calendar.day.timeline.left")
          .font(.title)
          .foregroundStyle(CalnoraTheme.accent)
          .padding(14)
          .background(CalnoraTheme.accent.opacity(0.12), in: .rect(cornerRadius: 18))
          .accessibilityHidden(true)
      }

      Text("A calm command center for meetings, recovery, deep work, and the small pockets of time that make the week feel intentional.")
        .font(.body)
        .foregroundStyle(CalnoraTheme.mutedInk)
        .fixedSize(horizontal: false, vertical: true)
    }
    .calnoraPanel()
  }
}
