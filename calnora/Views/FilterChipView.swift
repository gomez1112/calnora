import SwiftUI

struct FilterChipView: View {
  var title: String
  var tint: Color
  var isSelected: Bool
  var action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.caption)
        .bold()
        .lineLimit(1)
        .minimumScaleFactor(0.8)
        .foregroundStyle(isSelected ? .white : tint)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(isSelected ? tint : tint.opacity(0.12), in: .rect(cornerRadius: 14))
    }
    .buttonStyle(.plain)
  }
}
