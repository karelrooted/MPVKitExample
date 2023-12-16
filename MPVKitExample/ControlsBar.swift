import Defaults
import SwiftUI

struct ControlsBar: View {
    enum ExpansionState {
        case mini
        case full
    }

    @Binding var fullScreen: Bool
    @State private var presentingShareSheet = false
    @State private var shareURL: URL?
    @Binding var expansionState: ExpansionState

    @State var gestureThrottle = Throttle(interval: 0.25) // swiftlint:disable:this swiftui_state_private

    var presentingControls = true
    var backgroundEnabled = true
    var detailsTogglePlayer = true
    var detailsToggleFullScreen = false
    var playerBar = false
    var titleLineLimit = 2

    @ObservedObject private var model = PlayerModel.shared
    @ObservedObject private var controls = PlayerControlsModel.shared

    private let navigation = NavigationModel.shared
    private let controlsOverlayModel = ControlOverlaysModel.shared

    @Default(.playerButtonShowsControlButtonsWhenMinimized) private var controlsWhenMinimized
    @Default(.playerButtonSingleTapGesture) private var playerButtonSingleTapGesture
    @Default(.playerButtonDoubleTapGesture) private var playerButtonDoubleTapGesture

    var body: some View {
        HStack(spacing: 0) {
            detailsButton

            if presentingControls, expansionState == .full || (controlsWhenMinimized && model.currentItem != nil) {
                if expansionState == .full {
                    Spacer()
                }
                controlsView
                    .frame(maxWidth: 120)
            }
        }

        .buttonStyle(.plain)
        .labelStyle(.iconOnly)
        .padding(.horizontal, 10)
        .padding(.vertical, 2)
        .frame(maxHeight: barHeight)
        .padding(.trailing, expansionState == .mini && !controlsWhenMinimized ? 8 : 0)
        .modifier(ControlBackgroundModifier(enabled: backgroundEnabled))
        .clipShape(RoundedRectangle(cornerRadius: expansionState == .full || !playerBar ? 0 : 6))
        .overlay(
            RoundedRectangle(cornerRadius: expansionState == .full || !playerBar ? 0 : 6)
                .stroke(Color("ControlsBorderColor"), lineWidth: 0.5)
        )
        #if os(iOS)
        .background(
            EmptyView().sheet(isPresented: $presentingShareSheet) {
                if let shareURL {
                    ShareSheet(activityItems: [shareURL])
                }
            }
        )
        #endif
    }

    @ViewBuilder var detailsButton: some View {
        if detailsTogglePlayer {
            Button {
                model.togglePlayer()
            } label: {
                details
                    .contentShape(Rectangle())
            }
        } else if detailsToggleFullScreen {
            Button {
                controlsOverlayModel.hide()
                controls.presentingControls = false
                withAnimation {
                    fullScreen.toggle()
                }
            } label: {
                details
                    .contentShape(Rectangle())
            }
            #if !os(tvOS)
            .keyboardShortcut("t")
            #endif
        } else {
            details
        }
    }

    var controlsView: some View {
        HStack(spacing: 4) {
            Group {
                if controls.isPlaying {
                    Button(action: {
                        model.pause()
                    }) {
                        Label("Pause", systemImage: "pause.fill")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                } else {
                    Button(action: {
                        model.play()
                    }) {
                        Label("Play", systemImage: "play.fill")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                }
            }
            .disabled(controls.isLoadingVideo || model.currentItem.isNil)

            Button(action: { model.advanceToNextItem() }) {
                Label("Next", systemImage: "forward.fill")
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .disabled(!model.isAdvanceToNextItemAvailable)

            Button {
                model.closeCurrentItem()
            } label: {
                Label("Close Video", systemImage: "xmark")
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
            }
            .disabled(model.currentItem.isNil)
        }
        .imageScale(.small)
        .font(.system(size: 24))
    }

    var barHeight: Double {
        55
    }

    var details: some View {
        HStack {
            HStack(spacing: 8) {

                if expansionState == .full {
                    VStack(alignment: .leading, spacing: 0) {
                        let notPlaying = "Not Playing".localized()
                        Text(model.videoForDisplay?.displayTitle ?? notPlaying)
                            .font(.system(size: 14))
                            .fontWeight(.semibold)
                            .foregroundColor(model.videoForDisplay.isNil ? .secondary : .accentColor)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(titleLineLimit)
                            .multilineTextAlignment(.leading)

                        if let video = model.videoForDisplay, !video.localStreamIsFile {
                            HStack(spacing: 2) {
                                if !presentingControls && !video.isLocal {
                                    HStack(spacing: 2) {
                                        Image(systemName: "person.2.fill")

                                        
                                    }
                                    .padding(.leading, 4)
                                    .font(.system(size: 9))
                                }
                            }
                            .lineLimit(1)
                            .foregroundColor(.secondary)
                        }
                    }
                    .zIndex(0)
                    .transition(.opacity)

                    if !playerBar {
                        Spacer()
                    }
                }
            }
            .buttonStyle(.plain)
            .padding(.vertical)
        }
    }

    #if !os(tvOS)

        var singleTapGesture: some Gesture {
            TapGesture(count: 1).onEnded { gestureAction(playerButtonSingleTapGesture) }
        }

        var doubleTapGesture: some Gesture {
            TapGesture(count: 2).onEnded { gestureAction(playerButtonDoubleTapGesture) }
        }

        func gestureAction(_ action: PlayerTapGestureAction) {
            gestureThrottle.execute {
                switch action {
                case .togglePlayer:
                    self.model.togglePlayer()
                case .togglePlayerVisibility:
                    withAnimation(.spring(response: 0.25)) {
                        self.expansionState = self.expansionState == .full ? .mini : .full
                    }
                default:
                    return
                }
            }
        }
    #endif
    @ViewBuilder var contextMenu: some View {
        if let video = model.videoForDisplay {
            Group {
                

                Button {
                    model.closeCurrentItem()
                } label: {
                    Label("Close Video", systemImage: "xmark")
                }
            }
            .labelStyle(.automatic)
        }
    }
}

struct ControlsBar_Previews: PreviewProvider {
    static var previews: some View {
        ControlsBar(fullScreen: .constant(false), expansionState: .constant(.full))
            .injectFixtureEnvironmentObjects()
    }
}
