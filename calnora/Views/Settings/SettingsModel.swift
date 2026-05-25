import Observation
import Foundation

@Observable
final class SettingsModel {
    var showingDisclaimer = false
    var isExporting = false
    var exportURL: URL?
    var exportErrorMessage: String?
}
