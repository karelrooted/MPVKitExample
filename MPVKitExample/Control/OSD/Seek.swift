import Defaults
import SwiftUI

struct Seek: View {
    #if os(iOS)
        @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif

    @ObservedObject private var controls = PlayerControlsModel.shared
    @StateObject private var model = SeekModel.shared

    private var updateThrottle = Throttle(interval: 2)

    @Default(.playerControlsLayout) private var regularPlayerControlsLayout
    @Default(.fullScreenPlayerControlsLayout) private var fullScreenPlayerControlsLayout

    var body: some View {
        Group {
            #if os(tvOS)
                content
                    .shadow(radius: 3)
            #else
                Button(action: model.restoreTime) { content }
                    .buttonStyle(.plain)
            #endif
        }
        .opacity(visible ? 1 : 0)
    }

    var content: some View {
        VStack(spacing: playerControlsLayout.osdSpacing) {
            ProgressBar(value: model.progress)
                .frame(maxHeight: playerControlsLayout.osdProgressBarHeight)

            timeline

            if model.isSeeking {
                Divider()
                gestureSeekTime
                    .foregroundColor(.secondary)
                    .font(.system(size: playerControlsLayout.chapterFontSize).monospacedDigit())
                    .frame(height: playerControlsLayout.chapterFontSize + 5)

            } else {
                #if !os(tvOS)
                    if !model.restoreSeekTime.isNil {
                        Divider()
                        Label(model.restoreSeekPlaybackTime, systemImage: "arrow.counterclockwise")
                            .foregroundColor(.secondary)
                            .font(.system(size: playerControlsLayout.chapterFontSize).monospacedDigit())
                            .frame(height: playerControlsLayout.chapterFontSize + 5)
                    }
                #endif
                Group {
                    switch model.lastSeekType {
                    case let .segmentSkip(category):
                        Divider()
                        Text("Sponsor")
                            .font(.system(size: playerControlsLayout.segmentFontSize))
                            .foregroundColor(Color("AppRedColor"))
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .frame(maxWidth: playerControlsLayout.seekOSDWidth)
        #if os(tvOS)
            .padding(30)
        #else
            .padding(2)
            .modifier(ControlBackgroundModifier())
            .clipShape(RoundedRectangle(cornerRadius: 3))
        #endif

            .foregroundColor(.primary)
    }

    var timeline: some View {
        let text = model.isSeeking ?
            "\(model.gestureSeekDestinationPlaybackTime)/\(model.durationPlaybackTime)" :
            "\(model.lastSeekPlaybackTime)/\(model.durationPlaybackTime)"

        return Text(text)
            .fontWeight(.bold)
            .font(.system(size: playerControlsLayout.projectedTimeFontSize).monospacedDigit())
    }

    var gestureSeekTime: some View {
        var seek = model.gestureSeekDestinationTime - model.currentTime.seconds
        if seek > 0 {
            seek = min(seek, model.duration.seconds - model.currentTime.seconds)
        } else {
            seek = min(seek, model.currentTime.seconds)
        }
        let timeText = abs(seek)
            .formattedAsPlaybackTime(allowZero: true, forceHours: model.forceHours) ?? ""

        return Label(
            timeText,
            systemImage: seek >= 0 ? "goforward.plus" : "gobackward.minus"
        )
    }

    var visible: Bool {
        return false
        if let type = model.lastSeekType, !type.presentable { return false }

        return !controls.presentingControls && !controls.presentingOverlays && model.presentingOSD
    }

    var playerControlsLayout: PlayerControlsLayout {
        (model.player?.playingFullScreen ?? false) ? fullScreenPlayerControlsLayout : regularPlayerControlsLayout
    }
}

struct Seek_Previews: PreviewProvider {
    static var previews: some View {
        Seek()
    }
}
