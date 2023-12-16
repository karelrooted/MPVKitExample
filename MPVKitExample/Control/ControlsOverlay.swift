import Defaults
import SwiftUI

struct ControlsOverlay: View {
    @ObservedObject private var player = PlayerModel.shared
    private var model = PlayerControlsModel.shared

    @State private var contentSize: CGSize = .zero

    @Default(.showMPVPlaybackStats) private var showMPVPlaybackStats

    #if os(tvOS)
        enum Field: Hashable {
            case qualityProfile
            case stream
            case increaseRate
            case decreaseRate
            case captions
        }

        @FocusState private var focusedField: Field?
        @State private var presentingButtonHintAlert = false
    #endif

    var body: some View {
        ScrollView {
            VStack {

                if showMPVPlaybackStats
                {
                    Section(header: controlsHeader("Statistics".localized())) {
                        PlaybackStatsView()
                    }
                    #if os(tvOS)
                    .frame(width: 400)
                    #else
                    .frame(width: 240)
                    #endif
                }
            }
            .overlay(
                GeometryReader { geometry in
                    Color.clear.onAppear {
                        contentSize = geometry.size
                    }
                }
            )
            #if os(tvOS)
            .padding(.horizontal, 40)
            #endif

            #if os(tvOS)
                Text("Press and hold remote button to open captions and quality menus")
                    .frame(maxWidth: 400)
                    .font(.caption)
                    .foregroundColor(.secondary)
            #endif
        }
        .frame(maxHeight: overlayHeight)
        #if os(tvOS)
            .alert(isPresented: $presentingButtonHintAlert) {
                Alert(title: Text("Press and hold to open this menu"))
            }
            .onAppear {
                focusedField = .qualityProfile
            }
        #endif
    }

    private var rateAndCaptionsLabel: String {
        "Rate & Captions"
    }

    private var overlayHeight: Double {
        #if os(tvOS)
            contentSize.height + 80.0
        #else
            contentSize.height
        #endif
    }

    private func controlsHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(.caption))
            .foregroundColor(.secondary)
    }

    @ViewBuilder private var rateButton: some View {
        #if os(macOS)
            ratePicker
                .labelsHidden()
                .frame(maxWidth: 100)
        #elseif os(iOS)
            Menu {
                ratePicker
            } label: {
                Text(player.rateLabel(player.currentRate))
                    .foregroundColor(.primary)
                    .frame(width: 123)
            }
            .transaction { t in t.animation = .none }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            .frame(width: 123, height: 40)
            .modifier(ControlBackgroundModifier())
            .mask(RoundedRectangle(cornerRadius: 3))
        #else
            Text(player.rateLabel(player.currentRate))
                .frame(minWidth: 120)
        #endif
    }

    var ratePicker: some View {
        Picker("Rate", selection: $player.currentRate) {
            ForEach(player.backend.suggestedPlaybackRates, id: \.self) { rate in
                Text(player.rateLabel(rate)).tag(rate)
            }
        }
        .transaction { t in t.animation = .none }
    }

    private var increaseRateButton: some View {
        let increasedRate = player.backend.suggestedPlaybackRates.first { $0 > player.currentRate }
        return Button {
            if let rate = increasedRate {
                player.currentRate = rate
            }
        } label: {
            Label("Increase rate", systemImage: "plus")
                .foregroundColor(.primary)
                .labelStyle(.iconOnly)
                .padding(8)
                .frame(width: 50, height: 40)
                .contentShape(Rectangle())
        }
        #if os(macOS)
        .buttonStyle(.bordered)
        #elseif os(iOS)
        .modifier(ControlBackgroundModifier())
        .clipShape(RoundedRectangle(cornerRadius: 4))
        #endif
        .disabled(increasedRate.isNil)
    }

    private var decreaseRateButton: some View {
        let decreasedRate = player.backend.suggestedPlaybackRates.last { $0 < player.currentRate }

        return Button {
            if let rate = decreasedRate {
                player.currentRate = rate
            }
        } label: {
            Label("Decrease rate", systemImage: "minus")
                .foregroundColor(.primary)
                .labelStyle(.iconOnly)
                .padding(8)
                .frame(width: 50, height: 40)
                .contentShape(Rectangle())
        }
        #if os(macOS)
        .buttonStyle(.bordered)
        #elseif os(iOS)
        .modifier(ControlBackgroundModifier())
        .clipShape(RoundedRectangle(cornerRadius: 4))
        #endif
        .disabled(decreasedRate.isNil)
    }

    private var rateButtonsSpacing: Double {
        #if os(tvOS)
            10
        #else
            8
        #endif
    }

    @ViewBuilder private var captionsButton: some View {
        #if os(macOS)
            captionsPicker
                .labelsHidden()
                .frame(maxWidth: 300)
        #elseif os(iOS)
            Menu {
                captionsPicker
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "text.bubble")
                    if let captions = captionsBinding.wrappedValue {
                        Text(captions.code)
                            .foregroundColor(.primary)
                    }
                }
                .frame(width: 240)
                .frame(height: 40)
            }
            .transaction { t in t.animation = .none }
            .buttonStyle(.plain)
            .foregroundColor(.primary)
            .frame(width: 240)
            .modifier(ControlBackgroundModifier())
            .mask(RoundedRectangle(cornerRadius: 3))
        #else
            ControlsOverlayButton(focusedField: $focusedField, field: .captions) {
                HStack(spacing: 8) {
                    Image(systemName: "text.bubble")
                    if let captions = captionsBinding.wrappedValue {
                        Text(captions.code)
                    }
                }
                .frame(maxWidth: 320)
            }
            .contextMenu {
                Button("Disabled") { captionsBinding.wrappedValue = nil }

                ForEach(player.currentVideo?.captions ?? []) { caption in
                    Button(caption.description) { 
                        captionsBinding.wrappedValue = caption
                    }
                }
                Button("Cancel", role: .cancel) {}
            }

        #endif
    }

    @ViewBuilder private var captionsPicker: some View {
        let captions = player.currentVideo?.captions ?? []
        Picker("Captions", selection: captionsBinding) {
            if captions.isEmpty {
                Text("Not available")
            } else {
                Text("Disabled").tag(Captions?.none)
            }
            ForEach(captions) { caption in
                Text(caption.description).tag(Optional(caption))
            }
        }
        .disabled(captions.isEmpty)
    }

    private var captionsBinding: Binding<Captions?> {
        .init(
            get: { player.mpvBackend.captions },
            set: {
                player.mpvBackend.captions = $0
                Defaults[.captionsLanguageCode] = $0?.code
            }
        )
    }
}

struct ControlsOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ControlsOverlay()
    }
}
