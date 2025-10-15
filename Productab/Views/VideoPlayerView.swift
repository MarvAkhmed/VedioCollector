//
//  VideoPlayerView.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import SwiftUI
import AVKit


// MARK: - Single Video Player with autoplay
struct VideoPlayerView: View {
    let video: Video
    @State private var player: AVPlayer?

    var body: some View {
        ZStack {
            if let url = URL(string: video.video_url) {
                VideoPlayer(player: player)
                    .onAppear {
                        player = AVPlayer(url: url)
                        player?.play()
                        player?.isMuted = false
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }
            } else {
                Color.black
                Text("Video not available")
                    .foregroundColor(.white)
            }

            VStack {
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(video.title ?? "")
                            .font(.title)
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
        .ignoresSafeArea()
    }
}

struct TikTokInsideFeedView: View {
    let videos: [Video]
    @State private var currentIndex: Int
    
    init(videos: [Video], startIndex: Int) {
        self.videos = videos
        _currentIndex = State(initialValue: startIndex)
    }
    
    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(videos.indices, id: \.self) { index in
                VideoPlayerView(video: videos[index])
                    .tag(index)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .indexViewStyle(.page(backgroundDisplayMode: .never))
    }
}
