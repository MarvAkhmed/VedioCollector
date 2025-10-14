//
//  VideoFeedView 2.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//
import SwiftUI
import AVKit

struct VideoFeedView: View {
    @StateObject private var viewModel = VideoFeedViewModel()

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                if viewModel.isLoading {
                    ProgressView("Loading videos...")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else if viewModel.videos.isEmpty {
                    Text("No videos found")
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: geometry.size.width))], spacing: 0) {
                            ForEach(viewModel.videos) { video in
                                NavigationLink(destination: VideoPlayerView(videoURL: video.video_url ?? "")) {
                                    VideoCellView(video: video)
                                        .frame(width: geometry.size.width, height: geometry.size.height)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchVideos()
            }
        }
    }
}
