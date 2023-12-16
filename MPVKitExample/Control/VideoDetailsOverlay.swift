import Defaults
import SwiftUI

struct VideoDetailsOverlay: View {
    @ObservedObject private var controls = PlayerControlsModel.shared

    var body: some View {
        Text("testing")
    }

    var fullScreenBinding: Binding<Bool> {
        .init(get: {
            controls.presentingDetailsOverlay
        }, set: { newValue in
            controls.presentingDetailsOverlay = newValue
        })
    }
}
