import Foundation
#if !os(macOS)
    import UIKit
#endif

extension PlayerModel {
    #if os(tvOS)
        var closeCurrentItemAction: UIAction {
            UIAction(title: "Close video", image: UIImage(systemName: "xmark")) { [weak self] _ in
                self?.closeCurrentItem()
            }
        }

        var switchToMPVAction: UIAction? {
            UIAction(title: "Switch to MPV", image: UIImage(systemName: "m.circle")) { _ in
                self.avPlayerBackend.controller?.dismiss(animated: false)
                self.changeActiveBackend(from: .appleAVPlayer, to: .mpv)
            }
        }

        private var rateMenu: UIMenu {
            UIMenu(title: "Playback rate", image: UIImage(systemName: rateMenuSystemImage), children: rateMenuActions)
        }

        private var rateMenuSystemImage: String {
            [0.0, 1.0].contains(currentRate) ? "speedometer" : (currentRate < 1.0 ? "tortoise.fill" : "hare.fill")
        }

        private var rateMenuActions: [UIAction] {
            PlayerModel.shared.backend.suggestedPlaybackRates.map { rate in
                let image = currentRate == rate ? UIImage(systemName: "checkmark") : nil

                return UIAction(title: rateLabel(rate), image: image) { _ in
                    DispatchQueue.main.async {
                        self.currentRate = rate
                    }
                }
            }
        }

        private var playbackModeMenu: UIMenu {
            UIMenu(title: "Playback Mode", image: UIImage(systemName: playbackMode.systemImage), children: playbackModeMenuActions)
        }

        private var playbackModeMenuActions: [UIAction] {
            PlaybackMode.allCases.map { mode in
                UIAction(title: mode.description, image: UIImage(systemName: mode.systemImage)) { _ in
                    DispatchQueue.main.async {
                        self.playbackMode = mode
                    }
                }
            }
        }
    #endif

    func rebuildTVMenu() {
        #if os(tvOS)
            avPlayerBackend.controller?.playerView.transportBarCustomMenuItems = [
                closeCurrentItemAction,
                rateMenu,
                playbackModeMenu,
                switchToMPVAction
            ].compactMap { $0 }
        #endif
    }
}
