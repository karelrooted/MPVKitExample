//
//  ContentView.swift
//  MPVKitExample
//
//  Created by karelrooted on 11/10/23.
//

import SwiftUI
import MPVKit

struct ContentView: View {
    @State var player = MPVPlayer(url: URL(string: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!)
    @State var isPlaying: Bool = true
    
    var body: some View {
        VStack {
            MPVVideoPlayer(player: player)
            
            HStack{
                Button {
                    isPlaying ? player.pause() : player.play()
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle" : "play.circle")
                        .foregroundColor(.white)
                        .font(.system(size: 60))
                        .padding()
                }
                /*
                Button {
                    player.close()
                } label: {
                    Image(systemName: "stop.circle")
                        .foregroundColor(.white)
                        .font(.system(size: 60))
                        .padding()
                }
                */
            }
        }
    }
}

#Preview {
    ContentView()
}
