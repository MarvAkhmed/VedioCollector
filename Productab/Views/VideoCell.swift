
//
//  VideoCell.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import SwiftUI

struct VideoCellView: View {
    let video: Video
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8) {
                // Thumbnail or video
                AsyncImage(url: URL(string: video.thumbnail_url)) { image in
                    image
                        .resizable()
                        .scaledToFit() // fit width, maintain aspect ratio
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } placeholder: {
                    Color.gray
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }

                // Optional: overlay or info
                VStack(alignment: .leading) {
                    Text(video.title ?? "No title")
                        .font(.headline)
                        .lineLimit(2)
                        .foregroundColor(.white)
                    Text("@\(video.author ?? "unknown")")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding()
                .background(Color.black.opacity(0.3))
                .frame(width: geometry.size.width, alignment: .leading)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
