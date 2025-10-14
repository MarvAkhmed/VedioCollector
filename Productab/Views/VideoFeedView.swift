//
//  VideoFeedView 2.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//
// VideoFeedView.swift
import SwiftUI

struct VideoFeedView: View {
    @StateObject private var viewModel = VideoFeedViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading videos...")
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(viewModel.videos.enumerated()), id: \.offset) { index, video in
                                NavigationLink(
                                    destination: VideoPlayerFeedView(videos: viewModel.videos, startIndex: index)
                                ) {
                                    VideoCellView(video: video)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Shorts")
            .onAppear {
                viewModel.fetchVideos()
            }
        }
    }
}
