import SwiftUI

struct PrivacyView: View {
    var body: some View {
        List {
            privacyRow(
                title: "Local-first storage",
                message: "Your meals, goals, coach notes, and purchase snapshots are stored locally with SwiftData by default.",
                symbolName: "externaldrive.badge.checkmark"
            )
            privacyRow(
                title: "Private AI where available",
                message: "Foundation Models run on device when available. Calnora falls back gracefully when unavailable.",
                symbolName: "sparkles"
            )
            privacyRow(
                title: "Approximate estimates",
                message: "AI nutrition estimates are informational, approximate, and always editable before saving.",
                symbolName: "slider.horizontal.3"
            )
            privacyRow(
                title: "No medical advice",
                message: "Calnora does not diagnose, treat, or provide medical-grade nutrition guidance.",
                symbolName: "checkmark.shield"
            )
            Section("Links") {
                LabeledContent("Privacy Policy", value: "https://example.com/privacy")
                LabeledContent("Terms", value: "https://example.com/terms")
            }
        }
        .navigationTitle("Privacy")
    }

    private func privacyRow(title: String, message: String, symbolName: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: symbolName)
                .foregroundStyle(CalnoraColors.coach)
        }
    }
}
