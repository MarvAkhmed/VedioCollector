//
//  VideoPlayerFeedView.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import SwiftUI
import AVKit


struct VideoPlayerFeedView: View {
    let videos: [Video]
    @State var currentIndex: Int

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(videos.indices, id: \.self) { index in
                            VideoPlayerView(video: videos[index])
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .id(index)
                        }
                    }
                }
                .onAppear {
                    scrollProxy.scrollTo(currentIndex, anchor: .top)
                }
            }
        }
        .ignoresSafeArea()
    }
}
