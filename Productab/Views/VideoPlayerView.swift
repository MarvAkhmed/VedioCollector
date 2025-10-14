//
//  VideoPlayerView.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoURL: String

    @State private var player: AVPlayer?

    var body: some View {
        GeometryReader { geometry in
            if let player = player {
                VideoPlayer(player: player)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                ProgressView("Loading video...")
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .onAppear {
                        if let url = URL(string: videoURL) {
                            player = AVPlayer(url: url)
                        }
                    }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
