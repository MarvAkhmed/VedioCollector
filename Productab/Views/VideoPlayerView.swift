//
//  VideoPlayerView.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//
// VideoPlayerView.swift
import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let video: Video
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            if let url = URL(string: video.video_url) {
                VideoPlayer(player: AVPlayer(url: url))
                    .onAppear {
                        player = AVPlayer(url: url)
                        player?.play()
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }
                    .ignoresSafeArea()
            } else {
                Color.black
                Text("Video not available")
                    .foregroundColor(.white)
            }

            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text(video.title ?? "")
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                        Text("@\(video.author ?? "")")
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
}
