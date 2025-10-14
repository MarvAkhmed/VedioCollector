//
//  VideoFeedView 2.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import SwiftUI

struct VideoFeedView: View {
    @StateObject var viewModel = VideoFeedViewModel()
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                if viewModel.isLoading {
                    ProgressView("Loading videos...")
                        .frame(width: geometry.size.width,
                               height: geometry.size.height,
                               alignment: .center)
                } else if let error = viewModel.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .frame(width: geometry.size.width,
                               height: geometry.size.height,
                               alignment: .center)
                } else if viewModel.videos.isEmpty {
                    Text("No videos found")
                        .frame(width: geometry.size.width,
                               height: geometry.size.height,
                               alignment: .center)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.videos) { video in
                                VideoCellView(video: video)
                                    .frame(width: geometry.size.width,
                                           height: geometry.size.height)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.fetchVideos() // fetch videos when view appears
            }
        }
    }
}
