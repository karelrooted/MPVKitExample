import Defaults
import Foundation
import SwiftUI
#if os(iOS)
    import UIKit
#endif

extension Defaults.Keys {
    static let instancesManifest = Key<String>("instancesManifest", default: "")
    static let countryOfPublicInstances = Key<String?>("countryOfPublicInstances")

    static let lastAccountIsPublic = Key<Bool>("lastAccountIsPublic", default: false)
   

    static let enableReturnYouTubeDislike = Key<Bool>("enableReturnYouTubeDislike", default: false)

    static let showHome = Key<Bool>("showHome", default: true)
    static let showOpenActionsInHome = Key<Bool>("showOpenActionsInHome", default: true)
    static let showQueueInHome = Key<Bool>("showQueueInHome", default: true)
    static let showOpenActionsToolbarItem = Key<Bool>("showOpenActionsToolbarItem", default: false)
    static let showFavoritesInHome = Key<Bool>("showFavoritesInHome", default: true)
    #if os(iOS)
        static let showDocuments = Key<Bool>("showDocuments", default: false)
    #endif
    static let homeHistoryItems = Key<Int>("homeHistoryItems", default: 10)
    

    static let playerButtonSingleTapGesture = Key<PlayerTapGestureAction>("playerButtonSingleTapGesture", default: .togglePlayer)
    static let playerButtonDoubleTapGesture = Key<PlayerTapGestureAction>("playerButtonDoubleTapGesture", default: .nothing)
    static let playerButtonShowsControlButtonsWhenMinimized = Key<Bool>("playerButtonShowsControlButtonsWhenMinimized", default: false)
    static let playerButtonIsExpanded = Key<Bool>("playerButtonIsExpanded", default: false)
    static let playerBarMaxWidth = Key<String>("playerBarMaxWidth", default: "600")

    #if !os(tvOS)
        #if os(macOS)
            static let accountPickerDisplaysUsernameDefault = true
        #else
            static let accountPickerDisplaysUsernameDefault = UIDevice.current.userInterfaceIdiom == .pad
        #endif
        static let accountPickerDisplaysUsername = Key<Bool>("accountPickerDisplaysUsername", default: accountPickerDisplaysUsernameDefault)
    #endif
    static let accountPickerDisplaysAnonymousAccounts = Key<Bool>("accountPickerDisplaysAnonymousAccounts", default: true)
    #if os(iOS)
        static let lockPortraitWhenBrowsing = Key<Bool>("lockPortraitWhenBrowsing", default: UIDevice.current.userInterfaceIdiom == .phone)
    #endif
    static let showUnwatchedFeedBadges = Key<Bool>("showUnwatchedFeedBadges", default: false)
    static let keepChannelsWithUnwatchedFeedOnTop = Key<Bool>("keepChannelsWithUnwatchedFeedOnTop", default: true)
    static let showToggleWatchedStatusButton = Key<Bool>("showToggleWatchedStatusButton", default: false)
    static let expandChannelDescription = Key<Bool>("expandChannelDescription", default: false)
    static let channelOnThumbnail = Key<Bool>("channelOnThumbnail", default: false)
    static let timeOnThumbnail = Key<Bool>("timeOnThumbnail", default: true)
    static let roundedThumbnails = Key<Bool>("roundedThumbnails", default: true)
    static let thumbnailsQuality = Key<ThumbnailsQuality>("thumbnailsQuality", default: .highest)

    static let captionsLanguageCode = Key<String?>("captionsLanguageCode")
    static let activeBackend = Key<PlayerBackendType>("activeBackend", default: .mpv)


    
    static let playerRate = Key<Double>("playerRate", default: 1.0)
    static let forceAVPlayerForLiveStreams = Key<Bool>("forceAVPlayerForLiveStreams", default: true)
    static let playerSidebar = Key<PlayerSidebarSetting>("playerSidebar", default: .defaultValue)

    #if os(iOS)
        static let playerControlsLayoutDefault = UIDevice.current.userInterfaceIdiom == .pad ? PlayerControlsLayout.medium : .small
        static let fullScreenPlayerControlsLayoutDefault = UIDevice.current.userInterfaceIdiom == .pad ? PlayerControlsLayout.medium : .small
    #elseif os(tvOS)
        static let playerControlsLayoutDefault = PlayerControlsLayout.tvRegular
        static let fullScreenPlayerControlsLayoutDefault = PlayerControlsLayout.tvRegular
    #else
        static let playerControlsLayoutDefault = PlayerControlsLayout.medium
        static let fullScreenPlayerControlsLayoutDefault = PlayerControlsLayout.medium
    #endif

    static let playerControlsLayout = Key<PlayerControlsLayout>("playerControlsLayout", default: playerControlsLayoutDefault)
    static let fullScreenPlayerControlsLayout = Key<PlayerControlsLayout>("fullScreenPlayerControlsLayout", default: fullScreenPlayerControlsLayoutDefault)
    static let avPlayerUsesSystemControls = Key<Bool>("avPlayerUsesSystemControls", default: true)
    static let horizontalPlayerGestureEnabled = Key<Bool>("horizontalPlayerGestureEnabled", default: true)
    static let seekGestureSpeed = Key<Double>("seekGestureSpeed", default: 0.5)
    static let seekGestureSensitivity = Key<Double>("seekGestureSensitivity", default: 30.0)
    static let showKeywords = Key<Bool>("showKeywords", default: false)
    #if !os(tvOS)
        static let showScrollToTopInComments = Key<Bool>("showScrollToTopInComments", default: true)
    #endif

    #if os(iOS)
        static let expandVideoDescriptionDefault = true
    #else
        static let expandVideoDescriptionDefault = true
    #endif
    static let expandVideoDescription = Key<Bool>("expandVideoDescription", default: expandVideoDescriptionDefault)

    static let showChannelAvatarInChannelsLists = Key<Bool>("showChannelAvatarInChannelsLists", default: true)
    static let showChannelAvatarInVideosListing = Key<Bool>("showChannelAvatarInVideosListing", default: true)

    #if os(tvOS)
        static let pauseOnHidingPlayerDefault = true
    #else
        static let pauseOnHidingPlayerDefault = false
    #endif
    static let pauseOnHidingPlayer = Key<Bool>("pauseOnHidingPlayer", default: pauseOnHidingPlayerDefault)

    #if !os(macOS)
        static let pauseOnEnteringBackground = Key<Bool>("pauseOnEnteringBackground", default: true)
    #endif
    static let closeVideoOnEOF = Key<Bool>("closeVideoOnEOF", default: false)
    static let closePiPOnNavigation = Key<Bool>("closePiPOnNavigation", default: false)
    static let closePiPOnOpeningPlayer = Key<Bool>("closePiPOnOpeningPlayer", default: false)
    #if !os(macOS)
        static let closePiPAndOpenPlayerOnEnteringForeground = Key<Bool>("closePiPAndOpenPlayerOnEnteringForeground", default: false)
    #endif
    static let closePlayerOnOpeningPiP = Key<Bool>("closePlayerOnOpeningPiP", default: false)

    
    static let saveLastPlayed = Key<Bool>("saveLastPlayed", default: false)
    static let playbackMode = Key<PlayerModel.PlaybackMode>("playbackMode", default: .queue)

    static let saveHistory = Key<Bool>("saveHistory", default: true)
    static let showWatchingProgress = Key<Bool>("showWatchingProgress", default: true)
    static let watchedThreshold = Key<Int>("watchedThreshold", default: 90)
    static let watchedVideoStyle = Key<WatchedVideoStyle>("watchedVideoStyle", default: .badge)
    static let watchedVideoBadgeColor = Key<WatchedVideoBadgeColor>("WatchedVideoBadgeColor", default: .red)
    static let watchedVideoPlayNowBehavior = Key<WatchedVideoPlayNowBehavior>("watchedVideoPlayNowBehavior", default: .continue)
    static let resetWatchedStatusOnPlaying = Key<Bool>("resetWatchedStatusOnPlaying", default: false)
    static let saveRecents = Key<Bool>("saveRecents", default: true)


    static let visibleSections = Key<Set<VisibleSection>>("visibleSections", default: [.subscriptions, .trending, .playlists])
    static let startupSection = Key<StartupSection>("startupSection", default: .home)

    #if os(iOS)
        static let honorSystemOrientationLock = Key<Bool>("honorSystemOrientationLock", default: true)
        static let enterFullscreenInLandscape = Key<Bool>("enterFullscreenInLandscape", default: UIDevice.current.userInterfaceIdiom == .phone)
        static let rotateToLandscapeOnEnterFullScreen = Key<FullScreenRotationSetting>(
            "rotateToLandscapeOnEnterFullScreen",
            default: UIDevice.current.userInterfaceIdiom == .phone ? .landscapeRight : .disabled
        )
    #endif

    static let showMPVPlaybackStats = Key<Bool>("showMPVPlaybackStats", default: false)
    static let showPlayNowInBackendContextMenu = Key<Bool>("showPlayNowInBackendContextMenu", default: false)

    #if os(macOS)
        static let playerDetailsPageButtonLabelStyleDefault = ButtonLabelStyle.iconAndText
    #else
        static let playerDetailsPageButtonLabelStyleDefault = UIDevice.current.userInterfaceIdiom == .phone ? ButtonLabelStyle.iconOnly : .iconAndText
    #endif
    static let playerActionsButtonLabelStyle = Key<ButtonLabelStyle>("playerActionsButtonLabelStyle", default: .iconAndText)

    static let systemControlsCommands = Key<SystemControlsCommands>("systemControlsCommands", default: .restartAndAdvanceToNext)

    static let buttonBackwardSeekDuration = Key<String>("buttonBackwardSeekDuration", default: "10")
    static let buttonForwardSeekDuration = Key<String>("buttonForwardSeekDuration", default: "10")
    static let gestureBackwardSeekDuration = Key<String>("gestureBackwardSeekDuration", default: "10")
    static let gestureForwardSeekDuration = Key<String>("gestureForwardSeekDuration", default: "10")
    static let systemControlsSeekDuration = Key<String>("systemControlsBackwardSeekDuration", default: "10")
    static let actionButtonShareEnabled = Key<Bool>("actionButtonShareEnabled", default: true)
    static let actionButtonAddToPlaylistEnabled = Key<Bool>("actionButtonAddToPlaylistEnabled", default: true)
    static let actionButtonSubscribeEnabled = Key<Bool>("actionButtonSubscribeEnabled", default: false)
    static let actionButtonSettingsEnabled = Key<Bool>("actionButtonSettingsEnabled", default: true)
    static let actionButtonHideEnabled = Key<Bool>("actionButtonHideEnabled", default: false)
    static let actionButtonCloseEnabled = Key<Bool>("actionButtonCloseEnabled", default: true)
    static let actionButtonFullScreenEnabled = Key<Bool>("actionButtonFullScreenEnabled", default: false)
    static let actionButtonPipEnabled = Key<Bool>("actionButtonPipEnabled", default: false)
    static let actionButtonLockOrientationEnabled = Key<Bool>("actionButtonLockOrientationEnabled", default: false)
    static let actionButtonRestartEnabled = Key<Bool>("actionButtonRestartEnabled", default: false)
    static let actionButtonAdvanceToNextItemEnabled = Key<Bool>("actionButtonAdvanceToNextItemEnabled", default: false)
    static let actionButtonMusicModeEnabled = Key<Bool>("actionButtonMusicModeEnabled", default: true)

    static let queue = Key<[PlayerQueueItem]>("queue", default: [])
    #if os(iOS)
        static let playerControlsLockOrientationEnabled = Key<Bool>("playerControlsLockOrientationEnabled", default: true)
    #endif
    #if os(tvOS)
        static let playerControlsSettingsEnabledDefault = true
    #else
        static let playerControlsSettingsEnabledDefault = false
    #endif
    static let playerControlsSettingsEnabled = Key<Bool>("playerControlsSettingsEnabled", default: playerControlsSettingsEnabledDefault)
    static let playerControlsCloseEnabled = Key<Bool>("playerControlsCloseEnabled", default: true)
    static let playerControlsRestartEnabled = Key<Bool>("playerControlsRestartEnabled", default: false)
    static let playerControlsAdvanceToNextEnabled = Key<Bool>("playerControlsAdvanceToNextEnabled", default: false)
    static let playerControlsPlaybackModeEnabled = Key<Bool>("playerControlsPlaybackModeEnabled", default: false)
    static let playerControlsMusicModeEnabled = Key<Bool>("playerControlsMusicModeEnabled", default: false)

    static let mpvCacheSecs = Key<String>("mpvCacheSecs", default: "120")
    static let mpvCachePauseWait = Key<String>("mpvCachePauseWait", default: "3")
    static let mpvEnableLogging = Key<Bool>("mpvEnableLogging", default: false)

    static let showCacheStatus = Key<Bool>("showCacheStatus", default: false)
    static let feedCacheSize = Key<String>("feedCacheSize", default: "50")

    
    static let hideShorts = Key<Bool>("hideShorts", default: false)
    static let hideWatched = Key<Bool>("hideWatched", default: false)
    static let showChapters = Key<Bool>("showChapters", default: true)
    static let showRelated = Key<Bool>("showRelated", default: true)
}

enum ResolutionSetting: String, CaseIterable, Defaults.Serializable {
    case hd2160p60
    case hd2160p30
    case hd1440p60
    case hd1440p30
    case hd1080p60
    case hd1080p30
    case hd720p60
    case hd720p30
    case sd480p30
    case sd360p30
    case sd240p30
    case sd144p30

    var value: Stream.Resolution! {
        .init(rawValue: rawValue)
    }

    var description: String {
        switch self {
        case .hd2160p60:
            return "4K, 60fps"
        case .hd2160p30:
            return "4K"
        default:
            return value.name
        }
    }
}

enum PlayerSidebarSetting: String, CaseIterable, Defaults.Serializable {
    case always, whenFits, never

    static var defaultValue: Self {
        #if os(macOS)
            .always
        #else
            .whenFits
        #endif
    }
}

enum VisibleSection: String, CaseIterable, Comparable, Defaults.Serializable {
    case subscriptions, popular, trending, playlists

    var title: String {
        rawValue.capitalized
    }

    private var sortOrder: Int {
        switch self {
        case .subscriptions:
            return 0
        case .popular:
            return 1
        case .trending:
            return 2
        case .playlists:
            return 3
        }
    }

    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.sortOrder < rhs.sortOrder
    }
}

enum StartupSection: String, CaseIterable, Defaults.Serializable {
    case home, subscriptions, popular, trending, playlists, search

    var label: String {
        rawValue.capitalized
    }
}

enum WatchedVideoStyle: String, Defaults.Serializable {
    case nothing, badge, decreasedOpacity, both

    var isShowingBadge: Bool {
        self == .badge || self == .both
    }

    var isDecreasingOpacity: Bool {
        self == .decreasedOpacity || self == .both
    }
}

enum WatchedVideoBadgeColor: String, Defaults.Serializable {
    case colorSchemeBased, red, blue
}

enum WatchedVideoPlayNowBehavior: String, Defaults.Serializable {
    case `continue`, restart
}

enum ButtonLabelStyle: String, CaseIterable, Defaults.Serializable {
    case iconOnly, iconAndText

    var text: Bool {
        self == .iconAndText
    }
}

enum ThumbnailsQuality: String, CaseIterable, Defaults.Serializable {
    case highest, medium, low

    var description: String {
        switch self {
        case .highest:
            return "Highest quality"
        case .medium:
            return "Medium quality"
        case .low:
            return "Low quality"
        }
    }
}

enum SystemControlsCommands: String, CaseIterable, Defaults.Serializable {
    case seek, restartAndAdvanceToNext
}

enum ShowInspectorSetting: String, Defaults.Serializable {
    case always, onlyLocal
}

enum DetailsToolbarPositionSetting: String, CaseIterable, Defaults.Serializable {
    case left, center, right

    var needsLeftSpacer: Bool {
        self == .center || self == .right
    }

    var needsRightSpacer: Bool {
        self == .center || self == .left
    }
}

enum PlayerTapGestureAction: String, CaseIterable, Defaults.Serializable {
    case togglePlayerVisibility
    case togglePlayer
    case openChannel
    case nothing

    var label: String {
        switch self {
        case .togglePlayerVisibility:
            return "Toggle size"
        case .togglePlayer:
            return "Toggle player"
        case .openChannel:
            return "Open channel"
        case .nothing:
            return "Do nothing"
        }
    }
}

enum FullScreenRotationSetting: String, CaseIterable, Defaults.Serializable {
    case disabled
    case landscapeLeft
    case landscapeRight

    #if os(iOS)
        var interaceOrientation: UIInterfaceOrientation {
            switch self {
            case .landscapeLeft:
                return .landscapeLeft
            case .landscapeRight:
                return .landscapeRight
            default:
                return .portrait
            }
        }
    #endif

    var isRotating: Bool {
        self != .disabled
    }
}

struct WidgetSettings: Defaults.Serializable {
    static let defaultLimit = 10
    static let maxLimit: [WidgetListingStyle: Int] = [
        .horizontalCells: 50,
        .list: 50
    ]

    static var bridge = WidgetSettingsBridge()

    var id: String
    var listingStyle = WidgetListingStyle.horizontalCells
    var limit = Self.defaultLimit

    var viewID: String {
        "\(id)-\(listingStyle.rawValue)-\(limit)"
    }

    static func maxLimit(_ style: WidgetListingStyle) -> Int {
        maxLimit[style] ?? defaultLimit
    }
}

struct WidgetSettingsBridge: Defaults.Bridge {
    typealias Value = WidgetSettings
    typealias Serializable = [String: String]

    func serialize(_ value: Value?) -> Serializable? {
        guard let value else { return nil }

        return [
            "id": value.id,
            "listingStyle": value.listingStyle.rawValue,
            "limit": String(value.limit)
        ]
    }

    func deserialize(_ object: Serializable?) -> Value? {
        guard let object, let id = object["id"], !id.isEmpty else { return nil }
        var listingStyle = WidgetListingStyle.horizontalCells
        if let style = object["listingStyle"] {
            listingStyle = WidgetListingStyle(rawValue: style) ?? .horizontalCells
        }
        let limit = Int(object["limit"] ?? "\(WidgetSettings.defaultLimit)") ?? WidgetSettings.defaultLimit

        return Value(
            id: id,
            listingStyle: listingStyle,
            limit: limit
        )
    }
}

enum WidgetListingStyle: String, CaseIterable, Defaults.Serializable {
    case horizontalCells
    case list
}
