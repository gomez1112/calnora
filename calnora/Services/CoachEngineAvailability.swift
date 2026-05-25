import Foundation

#if canImport(FoundationModels)
import FoundationModels
#endif

enum CoachEngineAvailability {
    static func makeEngine() -> any CoachEngine {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *),
           SystemLanguageModel.default.availability == .available {
            return FoundationModelsCoachEngine()
        }
        #endif

        return MockCoachEngine()
    }

    static var userFacingStatus: String {
        #if canImport(FoundationModels)
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            switch SystemLanguageModel.default.availability {
            case .available:
                return "Private on-device AI is available."
            case .unavailable(.appleIntelligenceNotEnabled):
                return "Apple Intelligence is off. Calnora will use local fallback estimates."
            case .unavailable(.modelNotReady):
                return "Apple Intelligence is getting ready. Calnora will use local fallback estimates."
            case .unavailable(.deviceNotEligible):
                return "This device is not eligible for Foundation Models. Calnora will use local fallback estimates."
            @unknown default:
                return "Calnora will use local fallback estimates."
            }
        }
        #endif

        return "Foundation Models are unavailable. Calnora will use local fallback estimates."
    }
}
