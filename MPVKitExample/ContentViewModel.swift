import Combine
import Foundation
import MPVKit

class ContentViewModel: ObservableObject {

    @Published
    var ticks: Int = 0
    @Published
    var playerState: MPVVideoPlayer.State = .opening
    @Published
    var position: Float = 0
    @Published
    var totalTicks: Int = 0

    let proxy: MPVVideoPlayer.Proxy = .init()

    var configuration: MPVVideoPlayer.Configuration {
        let configuration = MPVVideoPlayer
            .Configuration(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
        configuration.autoPlay = true
        return configuration
    }

    var positiveTimeLabel: String {
        (ticks.roundDownNearestThousand / 1000).timeLabel
    }

    var negativeTimeLabel: String {
        ((totalTicks.roundDownNearestThousand - ticks.roundDownNearestThousand) / 1000).timeLabel
    }

    func setCustomPosition(_ newPosition: Float) {
        position = newPosition
    }

    func onStateUpdated(_ newState: MPVVideoPlayer.State, _ playbackInformation: MPVVideoPlayer.PlaybackInformation) {
        playerState = newState
    }

    func onTicksUpdated(_ newTicks: Int, _ playbackInformation: MPVVideoPlayer.PlaybackInformation) {
        position = playbackInformation.position
        ticks = newTicks
        totalTicks = playbackInformation.length
    }
}
