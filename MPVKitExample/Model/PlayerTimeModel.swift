import CoreMedia
import Foundation
import SwiftUI

final class PlayerTimeModel: ObservableObject {
    static let shared = PlayerTimeModel()
    static let timePlaceholder = "--:--"

    @Published var currentTime = CMTime.zero
    @Published var duration = CMTime.zero

    var player: PlayerModel { .shared }

    var forceHours: Bool {
        duration.seconds >= 60 * 60
    }
}
