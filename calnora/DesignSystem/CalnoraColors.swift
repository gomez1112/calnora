import SwiftUI

#if os(macOS)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif

enum CalnoraColors {
    static let calories = Color(red: 0.93, green: 0.32, blue: 0.42)
    static let protein = Color(red: 0.20, green: 0.46, blue: 0.92)
    static let carbs = Color(red: 0.90, green: 0.56, blue: 0.18)
    static let fat = Color(red: 0.17, green: 0.68, blue: 0.55)
    static let water = Color(red: 0.10, green: 0.65, blue: 0.86)
    static let coach = Color(red: 0.42, green: 0.30, blue: 0.86)
    static let success = Color.green
    static let warning = Color.yellow
    static let ink = Color(red: 0.11, green: 0.10, blue: 0.09)
    static let warmSurface = Color(red: 1.00, green: 0.97, blue: 0.93)
    static let sageSurface = Color(red: 0.92, green: 0.97, blue: 0.94)
    static let blushSurface = Color(red: 1.00, green: 0.93, blue: 0.92)

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
            colors: [carbs, calories, coach],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var calmGradient: LinearGradient {
        LinearGradient(
            colors: [fat.opacity(0.55), water.opacity(0.35), coach.opacity(0.22)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var ambientGradient: LinearGradient {
        LinearGradient(
            colors: [
                blushSurface.opacity(0.72),
                warmSurface.opacity(0.80),
                sageSurface.opacity(0.68),
                water.opacity(0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [
                calories.opacity(0.95),
                carbs.opacity(0.72),
                fat.opacity(0.58)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func calnoraAmbientBackground() -> some View {
        background {
            ZStack {
                CalnoraColors.groupedBackground
                CalnoraColors.ambientGradient
                CalnoraColors.coach.opacity(0.06)
                    .blur(radius: 44)
                    .offset(x: 160, y: -260)
                CalnoraColors.fat.opacity(0.08)
                    .blur(radius: 52)
                    .offset(x: -180, y: 260)
            }
            .ignoresSafeArea()
        }
    }
}
