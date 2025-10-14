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
    @State var startIndex: Int

    var body: some View {
        TabView(selection: $startIndex) {
            ForEach(videos.indices, id: \.self) { index in
                VideoPlayerView(video: videos[index])
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .rotationEffect(.degrees(-90))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .rotationEffect(.degrees(90))
        .ignoresSafeArea()
    }
}

