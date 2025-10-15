//  VideoFeedView.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import SwiftUI

struct VideoFeedView: View {
    @StateObject private var viewModel = VideoFeedViewModel()
    @State private var selectedVideoIndex: Int? = nil
    @State private var navigationPath = NavigationPath()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack(path: $navigationPath) {
            GeometryReader { geometry in // ADD THIS GeometryReader
                ZStack(alignment: .bottom) {
                    Color.black
                        .ignoresSafeArea()
                    
                    mainContent
                    CustomTabBar(selectedTab: $selectedTab, geometry: geometry)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Int.self) { index in
                if index < viewModel.videos.count {
                    VideooPlayerView(videos: viewModel.videos, startIndex: index)
                }
            }
            .onAppear {
                if viewModel.videos.isEmpty {
                    viewModel.fetchVideos()
                }
            }
        }
    }

    
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading {
            loadingView
        } else if let error = viewModel.errorMessage {
            errorView(error)
        } else if viewModel.videos.isEmpty {
            emptyView
        } else {
            videoScrollView
        }
    }
    
    private var loadingView: some View {
        ProgressView("Loading videos...")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundColor(.white)
    }
    
    private func errorView(_ error: String) -> some View {
        VStack {
            Text("Error: \(error)")
                .foregroundColor(.red)
            Button("Retry") {
                viewModel.fetchVideos()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        Text("No videos found")
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var videoScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 16) { // Increased spacing between cells
                ForEach(viewModel.videos.indices, id: \.self) { index in
                    let video = viewModel.videos[index]
                    NavigationLink(value: index) {
                        VideoCell(vm: VideoCellViewModel(video: video))
                            .padding(.horizontal, 16) // Add horizontal padding to each cell
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 8)
        }
        .background(Color.black)
    }
}
