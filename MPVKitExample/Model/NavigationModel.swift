import Foundation
import SwiftUI

final class NavigationModel: ObservableObject {
    static var shared = NavigationModel()

    var player = PlayerModel.shared

    enum TabSelection: Hashable {
        case home
        case documents
        case subscriptions
        case popular
        case trending
        case playlists
        case channel(String)
        case playlist(String)
        case recentlyOpened(String)
        case nowPlaying
        case search
        #if os(tvOS)
            case settings
        #endif

        var stringValue: String {
            switch self {
            case .home:
                return "favorites"
            case .subscriptions:
                return "subscriptions"
            case .popular:
                return "popular"
            case .trending:
                return "trending"
            case .playlists:
                return "playlists"
            case let .channel(string):
                return "channel\(string)"
            case let .playlist(string):
                return "playlist\(string)"
            case .recentlyOpened:
                return "recentlyOpened"
            case .search:
                return "search"
            #if os(tvOS)
                case .settings:
                    return "settings"
            #endif
            default:
                return ""
            }
        }
    }

    @Published var tabSelection: TabSelection! { didSet {
        if oldValue == tabSelection { multipleTapHandler() }
    }}

    @Published var presentingAddToPlaylist = false
    @Published var videoToAddToPlaylist: Video!

    @Published var presentingPlaylistForm = false

    @Published var presentingUnsubscribeAlert = false

    @Published var presentingChannel = false
    @Published var presentingPlaylist = false
    @Published var sidebarSectionChanged = false

    @Published var presentingPlaybackSettings = false
    @Published var presentingOpenVideos = false
    @Published var presentingSettings = false
    @Published var presentingAccounts = false
    @Published var presentingWelcomeScreen = false
    @Published var presentingHomeSettings = false

    @Published var presentingChannelSheet = false

    @Published var presentingShareSheet = false
    @Published var shareURL: URL?

    @Published var alert = Alert(title: Text("Error"))
    @Published var presentingAlert = false
    @Published var presentingAlertInOpenVideos = false
    #if os(macOS)
        @Published var presentingAlertInVideoPlayer = false
    #endif

    @Published var presentingFileImporter = false

    var tabSelectionBinding: Binding<TabSelection> {
        Binding<TabSelection>(
            get: {
                self.tabSelection ?? .search
            },
            set: { newValue in
                self.tabSelection = newValue
            }
        )
    }

    func hideViewsAboveBrowser() {
        player.hide()
        presentingChannel = false
        presentingPlaylist = false
        presentingOpenVideos = false
    }

    func hideKeyboard() {
        #if os(iOS)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        #endif
    }

    func presentAlert(title: String, message: String? = nil) {
        let message = message.isNil ? nil : Text(message!)
        alert = Alert(title: Text(title), message: message)
        presentingAlert = true
    }

    func presentAlert(_ alert: Alert) {
        self.alert = alert
        presentingAlert = true
    }

    func presentShareSheet(_ url: URL) {
        shareURL = url
        presentingShareSheet = true
    }

    func multipleTapHandler() {
        switch tabSelection {
        default:
            print("not implemented")
        }
    }
}

typealias TabSelection = NavigationModel.TabSelection
