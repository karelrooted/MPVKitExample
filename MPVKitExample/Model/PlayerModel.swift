import AVKit
import CoreData
#if os(iOS)
    import CoreMotion
#endif
import Defaults
import Foundation
import Logging
import MediaPlayer
import SwiftUI
import SwiftyJSON
#if !os(macOS)
    import UIKit
#endif

final public class PlayerModel: ObservableObject {
    enum PlaybackMode: String, CaseIterable, Defaults.Serializable {
        case queue, shuffle, loopOne, related

        var systemImage: String {
            switch self {
            case .queue:
                return "list.number"
            case .shuffle:
                return "shuffle"
            case .loopOne:
                return "repeat.1"
            case .related:
                return "infinity"
            }
        }

        var description: String {
            switch self {
            case .queue:
                return "Queue"
            case .shuffle:
                return "Queue - shuffled"
            case .loopOne:
                return "Loop one"
            case .related:
                return "Autoplay next"
            }
        }
    }

    static var shared = PlayerModel()

    let logger = Logger(label: "stream.yattee.app")

    var playerItem: AVPlayerItem?

    var mpvPlayerView = MPVPlayerView()
    var seek: SeekModel { .shared }
    var controls: PlayerControlsModel { .shared }
    var navigation: NavigationModel { .shared }
    var presentingPlayer = true
    @Published var preservedTime: CMTime?
    @Published var autoplayItem: PlayerQueueItem?
    @Published var autoplayItemSource: Video?
    
    @Published var aspectRatio = MPVVideoPlayer.defaultAspectRatio
    @Published var stream: Stream?
    @Published var videoBeingOpened: Video? { didSet { seek.reset() } }
    @Published var availableStreams = [Stream]() { didSet { handleAvailableStreamsChange() } }
    @Published var streamSelection: Stream?
    
    @Published var queue = [PlayerQueueItem]() { didSet { handleQueueChange() } }
    @Published var currentItem: PlayerQueueItem! { didSet { handleCurrentItemChange() } }

    @Published var playbackMode = PlaybackMode.queue
    @Published var musicMode = false
    @Published var isSeeking = false
    @Published var advancing = false
    @Published var closing = false
    var onPresentPlayer = [() -> Void]()
    #if os(iOS)
        @Published var lockedOrientation: UIInterfaceOrientationMask?
        @Default(.rotateToLandscapeOnEnterFullScreen) private var rotateToLandscapeOnEnterFullScreen
    #endif
    
    @Published var playingInPictureInPicture = false
    var pipController: AVPictureInPictureController?
    var pipDelegate = PiPDelegate()
    #if !os(macOS)
        var appleAVPlayerViewControllerDelegate = AppleAVPlayerViewControllerDelegate()
    #endif
    
    @Default(.closePiPOnNavigation) var closePiPOnNavigation
    @Default(.closePiPOnOpeningPlayer) var closePiPOnOpeningPlayer
    @Default(.avPlayerUsesSystemControls) var avPlayerUsesSystemControls
    
    var currentVideoIsLandscape: Bool {
        guard currentVideo != nil else { return false }

        return aspectRatio > 1
    }
    
#if os(iOS)
    var lockOrientationImage: String {
        lockedOrientation.isNil ? "lock.rotation.open" : "lock.rotation"
    }

    func lockOrientationAction() {
        if lockedOrientation.isNil {
            let orientationMask = OrientationTracker.shared.currentInterfaceOrientationMask
            lockedOrientation = orientationMask
            let orientation = OrientationTracker.shared.currentInterfaceOrientation
            Orientation.lockOrientation(orientationMask, andRotateTo: .landscapeLeft)
            // iOS 16 workaround
            Orientation.lockOrientation(orientationMask, andRotateTo: orientation)
        } else {
            lockedOrientation = nil
            Orientation.lockOrientation(.allButUpsideDown, andRotateTo: OrientationTracker.shared.currentInterfaceOrientation)
        }
    }
#endif
    
    lazy var playerBackendView = PlayerBackendView()
    
    var live: Bool {
        currentVideo?.live ?? false
    }
    
    func enterFullScreen(showControls: Bool = true) {
        guard !playingFullScreen else { return }

        logger.info("entering fullscreen")
        toggleFullscreen(false, showControls: showControls)
    }
    
    
    
    @Published var playerSize: CGSize = .zero { didSet {
        #if !os(tvOS)
            #if os(macOS)
                guard videoForDisplay != nil else { return }
            #endif
            backend.setSize(playerSize.width, playerSize.height)
        #endif
    }}
    
    var time: CMTime? {
        currentItem?.playbackTime
    }
    
    #if os(tvOS)
        static let fullScreenIsDefault = true
    #else
        static let fullScreenIsDefault = false
    #endif
    @Published var playingFullScreen = PlayerModel.fullScreenIsDefault
    @Published var currentRate: Double = 1.0
    
    var playerError: Error? { didSet {
        if let error = playerError {
            navigation.presentAlert(title: "Failed loading video".localized(), message: error.localizedDescription)
        }
    }}
    
    @Published var activeBackend = PlayerBackendType.mpv
    @Published var forceBackendOnPlay: PlayerBackendType?

    var avPlayerBackend = AVPlayerBackend()
    var mpvBackend = MPVBackend()
    #if !os(macOS)
        var mpvController = MPVViewController()
    #endif

    var backends: [PlayerBackend] {
        [avPlayerBackend, mpvBackend]
    }

    var backend: PlayerBackend! {
        switch activeBackend {
        case .mpv:
            return mpvBackend
        case .appleAVPlayer:
            return avPlayerBackend
        }
    }

    init() {
        #if !os(macOS)
            mpvBackend.controller = mpvController
            mpvBackend.client = mpvController.client
        #endif
    }

    func show() {
        #if os(macOS)
            if presentingPlayer {
                Windows.player.focus()
                return
            }
        #endif

        #if os(iOS)
            Delay.by(0.5) {
                self.navigation.hideKeyboard()
            }
        #endif

        presentingPlayer = true

        #if os(macOS)
            Windows.player.open()
            Windows.player.focus()
        #endif
    }
    
    func handleQueueChange() {
        return
    }

    func handleCurrentItemChange() {
        return
    }

    func hide(animate: Bool = true) {
        if animate {
            withAnimation(.easeOut(duration: 0.2)) {
                presentingPlayer = false
            }
        } else {
            presentingPlayer = false
        }

        DispatchQueue.main.async { [weak self] in
            Delay.by(0.3) {
                self?.exitFullScreen(showControls: false)
            }
        }

        #if os(macOS)
            Windows.player.hide()
        #endif
    }
    
    func exitFullScreen(showControls: Bool = true) {
        //guard playingFullScreen else { return }

        logger.info("exiting fullscreen")
        toggleFullscreen(true, showControls: showControls)
    }


    func togglePlayer() {
        #if os(macOS)
            if !presentingPlayer {
                Windows.player.open()
            }
            Windows.player.focus()

            if Windows.player.visible,
               closePiPOnOpeningPlayer
            {
                closePiP()
            }

        #else
            if presentingPlayer {
                hide()
            } else {
                show()
            }
        #endif
    }

    var isLoadingVideo: Bool {
        return backend.isLoadingVideo
    }

    var isPlaying: Bool {
        backend.isPlaying
    }
    
    func togglePlay() {
        backend.togglePlay()
    }

    func play() {
        backend.play()
    }

    func pause() {
        backend.pause()
    }
    
    func updateAspectRatio() {
        #if !os(tvOS)
            guard aspectRatio != backend.aspectRatio else { return }

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                withAnimation {
                    self.aspectRatio = self.backend.aspectRatio
                }
            }
        #endif
    }
    
    private func handleAvailableStreamsChange() {
        guard stream.isNil else {
            return
        }

        let localStream = (availableStreams.count == 1 && availableStreams.first!.isLocal) ? availableStreams.first : nil

        guard let stream = localStream,
              let currentVideo
        else {
            return
        }

        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.streamSelection = stream
            }
            self.playStream(
                stream,
                of: currentVideo,
                preservingTime: !self.currentItem.playbackTime.isNil
            )
        }
    }
    
    func resetAutoplay() {
        autoplayItem = nil
        autoplayItemSource = nil
    }
    
    func closeCurrentItem(finished: Bool = false) {
        pause()
        videoBeingOpened = nil
        advancing = false
        forceBackendOnPlay = nil

        closing = true
        controls.presentingControls = false

        self.hide()

        Delay.by(0.8) { [weak self] in
            guard let self else { return }

            withAnimation {
                self.currentItem = nil
            }

            self.backend.closeItem()
            self.aspectRatio = MPVVideoPlayer.defaultAspectRatio
            self.resetAutoplay()
            self.closing = false
            self.playingFullScreen = false
        }
    }
   
    func playStream(
        _ stream: Stream,
        of video: Video,
        preservingTime: Bool = false,
        upgrading: Bool = false,
        withBackend: PlayerBackend? = nil
    ) {
        playerError = nil
        if !upgrading, !video.isLocal {

            DispatchQueue.main.async { [weak self] in

                guard Defaults[.enableReturnYouTubeDislike] else {
                    return
                }
            }
        }

        (withBackend ?? backend).playStream(
            stream,
            of: video,
            preservingTime: preservingTime,
            upgrading: upgrading
        )

        DispatchQueue.main.async {
            self.forceBackendOnPlay = nil
        }
    }
    
    func saveTime(completionHandler: @escaping () -> Void = {}) {
        guard let currentTime = backend.currentTime, currentTime.seconds > 0 else {
            completionHandler()
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.preservedTime = currentTime
            completionHandler()
        }
    }
    
    func rateLabel(_ rate: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2

        return "\(formatter.string(from: NSNumber(value: rate))!)×"
    }
    
    var fullscreenImage: String {
        playingFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right"
    }

    func toggleFullScreenAction() {
        toggleFullscreen(playingFullScreen, showControls: false)
    }
    
    func toggleFullscreen(_ isFullScreen: Bool, showControls: Bool = true) {
        controls.presentingControls = showControls && isFullScreen

        #if os(macOS)
            Windows.player.toggleFullScreen()
        #endif

        playingFullScreen = !isFullScreen

        #if os(iOS)
            if playingFullScreen {
                if activeBackend == .appleAVPlayer, avPlayerUsesSystemControls {
                    avPlayerBackend.controller.enterFullScreen(animated: true)
                    return
                }
                guard rotateToLandscapeOnEnterFullScreen.isRotating else { return }
                if currentVideoIsLandscape {
                    let delay = activeBackend == .appleAVPlayer && avPlayerUsesSystemControls ? 0.8 : 0
                    // not sure why but first rotation call is ignore so doing rotate to same orientation first
                    Delay.by(delay) {
                        let orientation = OrientationTracker.shared.currentDeviceOrientation.isLandscape ? OrientationTracker.shared.currentInterfaceOrientation : self.rotateToLandscapeOnEnterFullScreen.interaceOrientation
                        Orientation.lockOrientation(.allButUpsideDown, andRotateTo: OrientationTracker.shared.currentInterfaceOrientation)
                        Orientation.lockOrientation(.allButUpsideDown, andRotateTo: orientation)
                    }
                }
            } else {
                if activeBackend == .appleAVPlayer, avPlayerUsesSystemControls {
                    avPlayerBackend.controller.exitFullScreen(animated: true)
                    avPlayerBackend.controller.dismiss(animated: true)
                    return
                }
                let rotationOrientation = Constants.isIPhone ? UIInterfaceOrientation.portrait : nil
                Orientation.lockOrientation(.allButUpsideDown, andRotateTo: rotationOrientation)
            }

        #endif
    }
    
    func setNeedsDrawing(_ needsDrawing: Bool) {
        backends.forEach { $0.setNeedsDrawing(needsDrawing) }
    }
    
    func toggleMusicMode() {
        musicMode.toggle()

        if musicMode {
            aspectRatio = MPVVideoPlayer.defaultAspectRatio
            controls.presentingControls = true
            controls.removeTimer()

            backend.startMusicMode()
        } else {
            backend.stopMusicMode()
            Delay.by(0.25) {
                self.updateAspectRatio()
            }

            controls.resetTimer()
        }
    }
    
    func replayAction() {
        backend.seek(to: 0.0, seekType: .userInteracted)
    }
    
    func playUrl(url: URL) {
        backend.playUrl(
            url: url.absoluteString,
            preservingTime: false,
            upgrading: false
        )

        DispatchQueue.main.async {
            self.forceBackendOnPlay = nil
        }
    }
    
    func closePiP() {
        guard playingInPictureInPicture else {
            return
        }

        avPlayerBackend.startPictureInPictureOnPlay = false
        avPlayerBackend.startPictureInPictureOnSwitch = false

        #if os(tvOS)
            show()
        #endif

        backend.closePiP()
    }
    
    func changeActiveBackend(from: PlayerBackendType, to: PlayerBackendType, changingStream: Bool = true) {
        guard activeBackend != to else {
            return
        }

        logger.info("changing backend from \(from.rawValue) to \(to.rawValue)")

        let wasPlaying = isPlaying

        if to == .mpv {
            closePiP()
        }

        Defaults[.activeBackend] = to
        self.activeBackend = to

        let fromBackend: PlayerBackend = from == .appleAVPlayer ? avPlayerBackend : mpvBackend
        let toBackend: PlayerBackend = to == .appleAVPlayer ? avPlayerBackend : mpvBackend

        toBackend.cancelLoads()
        fromBackend.cancelLoads()

        if !self.backend.canPlayAtRate(currentRate) {
            currentRate = self.backend.suggestedPlaybackRates.last { $0 < currentRate } ?? 1.0
        }

        self.backend.didChangeTo()

        if wasPlaying {
            fromBackend.pause()
        }

        guard var stream, changingStream else {
            return
        }

        return
    }
    
    var transitioningToPiP: Bool {
        avPlayerBackend.startPictureInPictureOnPlay || avPlayerBackend.startPictureInPictureOnSwitch
    }
}
