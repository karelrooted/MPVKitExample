import Foundation

final class NetworkStateModel: ObservableObject {
    static var shared = NetworkStateModel()

    @Published var pausedForCache = false
    @Published var cacheDuration = 0.0
    @Published var bufferingState = 0.0

    private var player: PlayerModel! { .shared }
    private let controlsOverlayModel = ControlOverlaysModel.shared

    var osdVisible: Bool {
        return false
    }

    var fullStateText: String? {
        guard let bufferingStateText,
              let cacheDurationText
        else {
            return nil
        }

        return "\(bufferingStateText) (\(cacheDurationText))"
    }

    var bufferingStateText: String? {
        guard detailsAvailable else { return nil }
        return String(format: "%.0f%%", bufferingState)
    }

    var cacheDurationText: String? {
        guard detailsAvailable else { return nil }
        return String(format: "%.2fs", cacheDuration)
    }

    var detailsAvailable: Bool {
        guard let player else { return false }
        return true
    }

    var needsUpdates: Bool {
        return false
    }
}
