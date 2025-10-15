//
//  VideoFeedView.swift
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
                ZStack {
                    // Black background
                    Color.black
                        .ignoresSafeArea()
                    
                    if viewModel.isLoading {
                        ProgressView("Loading videos...")
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .foregroundColor(.white)
                    } else if let error = viewModel.errorMessage {
                        VStack {
                            Text("Error: \(error)")
                                .foregroundColor(.red)
                            Button("Retry") {
                                viewModel.fetchVideos()
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height)
                    } else if viewModel.videos.isEmpty {
                        Text("No videos found")
                            .foregroundColor(.white)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(viewModel.videos.indices, id: \.self) { index in
                                    let video = viewModel.videos[index]
                                    NavigationLink(
                                        destination: VideooPlayerView(videos: viewModel.videos, startIndex: index),
                                        tag: index,
                                        selection: $selectedVideoIndex,
                                        label: {
                                            VideoCell(video: video)
                                        }
                                    )
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .background(Color.black)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                if viewModel.videos.isEmpty {
                    viewModel.fetchVideos()
                }
            }
        }
    }
}
