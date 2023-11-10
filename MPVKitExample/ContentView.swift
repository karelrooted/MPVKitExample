import MPVKit
import SwiftUI

struct ContentView: View {
    @StateObject
    private var viewModel = ContentViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            MPVVideoPlayer(configuration: viewModel.configuration)
                .proxy(viewModel.proxy)
                .onStateUpdated(viewModel.onStateUpdated)
                .onTicksUpdated(viewModel.onTicksUpdated)

            OverlayView(viewModel: viewModel)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
}
