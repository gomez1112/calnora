import SwiftUI

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum CalnoraColors {
    static let calories = Color.pink
    static let protein = Color.blue
    static let carbs = Color.orange
    static let fat = Color.mint
    static let water = Color.cyan
    static let coach = Color.indigo
    static let success = Color.green
    static let warning = Color.yellow

    static var groupedBackground: Color {
        #if os(macOS)
        Color(nsColor: .windowBackgroundColor)
        #elseif canImport(UIKit)
        Color(uiColor: .systemGroupedBackground)
        #else
        Color.gray.opacity(0.08)
        #endif
    }

    static var premiumGradient: LinearGradient {
        LinearGradient(
            colors: [.orange, .pink, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var calmGradient: LinearGradient {
        LinearGradient(
            colors: [.mint.opacity(0.55), .cyan.opacity(0.35), .indigo.opacity(0.22)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Warm pink → peach → mint backdrop used on every primary screen.
    static var ambientGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.pink.opacity(0.10),
                Color.orange.opacity(0.06),
                Color.clear,
                Color.mint.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// Shared warm ambient backdrop. Use as the screen background.
    func calnoraAmbientBackground() -> some View {
        background {
            ZStack {
                CalnoraColors.groupedBackground
                CalnoraColors.ambientGradient
            }
            .ignoresSafeArea()
        }
    }
}
