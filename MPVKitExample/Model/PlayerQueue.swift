import AVKit
import Defaults
import Foundation
import MPVKit
import SwiftUI

extension PlayerModel {
    var currentVideo: Video? {
        currentItem?.video
    }

    var videoForDisplay: Video? {
        videoBeingOpened ?? currentVideo
    }

    func play(_ videos: [Video], shuffling: Bool = false) {
        navigation.presentingChannelSheet = false

        playbackMode = shuffling ? .shuffle : .queue

        videos.forEach { enqueueVideo($0, loadDetails: false) }

        #if os(iOS)
            onPresentPlayer.append { [weak self] in self?.advanceToNextItem() }
        #else
            advanceToNextItem()
        #endif

        show()
    }

    func playNext(_ video: Video) {
        enqueueVideo(video, play: currentItem.isNil, prepending: true)
    }

    func playNow(_ video: Video, at time: CMTime? = nil) {
        navigation.presentingChannelSheet = false

        videoBeingOpened = video

        enqueueVideo(video, play: true, atTime: time, prepending: true) { _, item in
            self.advanceToItem(item, at: time)
        }
    }

    func playItem(_ item: PlayerQueueItem, at time: CMTime? = nil) {
        advancing = false

        if !playingInPictureInPicture, !currentItem.isNil {
            backend.closeItem()
        }

        stream = nil
        navigation.presentingChannelSheet = false

        withAnimation {
            aspectRatio = MPVVideoPlayer.defaultAspectRatio
            currentItem = item
        }

        if !time.isNil {
            currentItem.playbackTime = time
        } else if currentItem.playbackTime.isNil {
            currentItem.playbackTime = .zero
        }

        preservedTime = currentItem.playbackTime

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            guard let video = item.video else {
                return
            }

            if video.isLocal {
                self.videoBeingOpened = nil
                self.availableStreams = video.streams
                return
            }
        }
    }

    func advanceToNextItem() {
        guard !advancing else {
            return
        }
        advancing = true

        var nextItem: PlayerQueueItem?
        switch playbackMode {
        case .queue:
            nextItem = queue.first
        case .shuffle:
            nextItem = queue.randomElement()
        case .related:
            nextItem = autoplayItem
        case .loopOne:
            nextItem = nil
        }

        resetAutoplay()

        if let nextItem {
            advanceToItem(nextItem)
        } else {
            advancing = false
        }
    }

    var isAdvanceToNextItemAvailable: Bool {
        switch playbackMode {
        case .loopOne:
            return false
        case .queue, .shuffle:
            return !queue.isEmpty
        case .related:
            return autoplayItem != nil
        }
    }

    func advanceToItem(_ newItem: PlayerQueueItem, at time: CMTime? = nil) {
        remove(newItem)

        navigation.presentingChannelSheet = false
        currentItem = newItem
        currentItem.playbackTime = time

        let playTime = currentItem.shouldRestartPlaying ? CMTime.zero : time
    }

    @discardableResult func remove(_ item: PlayerQueueItem) -> PlayerQueueItem? {
        return nil
    }

    func resetQueue() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                return
            }

            self.currentItem = nil
            self.stream = nil
            self.removeQueueItems()
        }

        backend.closeItem()
    }

    @discardableResult func enqueueVideo(
        _ video: Video,
        play: Bool = false,
        atTime: CMTime? = nil,
        prepending: Bool = false,
        loadDetails: Bool = true,
        videoDetailsLoadHandler: @escaping (Video, PlayerQueueItem) -> Void = { _, _ in }
    ) -> PlayerQueueItem? {
        let item = PlayerQueueItem(video, playbackTime: atTime)

        if play {
            navigation.presentingChannelSheet = false

            withAnimation {
                aspectRatio = MPVVideoPlayer.defaultAspectRatio
                navigation.presentingChannelSheet = false
                currentItem = item
            }
            videoBeingOpened = video
        }

        if loadDetails {
        } else {
            videoDetailsLoadHandler(video, item)
            queue.insert(item, at: prepending ? 0 : queue.endIndex)
        }

        return item
    }

    func removeQueueItems() {
        queue.removeAll()
    }

    func restoreQueue() {
        var restoredQueue = [PlayerQueueItem?]()

        restoredQueue.append(contentsOf: Defaults[.queue])
        queue = restoredQueue.compactMap { $0 }
    }

    private func videoLoadFailureHandler(_ message: String, video: Video? = nil) {
        var retryButton: Alert.Button?

        if let video {
            retryButton = Alert.Button.default(Text("Retry")) { [weak self] in
                if let self {
                    self.enqueueVideo(video, play: true, prepending: true, loadDetails: true)
                }
            }
        }

        var alert: Alert
        if let retryButton {
            alert = Alert(
                title: Text("Could not load video"),
                message: Text(message),
                primaryButton: .cancel { [weak self] in
                    guard let self else { return }
                    self.closeCurrentItem()
                },
                secondaryButton: retryButton
            )
        } else {
            alert = Alert(title: Text("Could not load video"))
        }

        navigation.presentAlert(alert)
    }
}
