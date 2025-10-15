//
//  VideoFeedView 2.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import SwiftUI

struct VideoFeedView: View {
    @StateObject private var viewModel = VideoFeedViewModel()
    @State private var selectedVideoIndex: Int? = nil

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
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.videos.indices, id: \.self) { index in
                                let video = viewModel.videos[index]
                                NavigationLink(
                                    destination: TikTokInsideFeedView(videos: viewModel.videos, startIndex: index),
                                    label: {
                                        VideoCellView(video: video)
                                            .frame(height: geometry.size.height * 0.6)
                                            .clipped()
                                    }
                                )
                            }
                        }
                        .padding()
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
