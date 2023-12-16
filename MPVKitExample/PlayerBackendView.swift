import Defaults
import SwiftUI

struct PlayerBackendView: View {
    @ObservedObject private var player = PlayerModel.shared

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                ZStack {
                    Group {
                        player.mpvPlayerView
                    }
                    .zIndex(0)
                }
            }
        }
    }
}
