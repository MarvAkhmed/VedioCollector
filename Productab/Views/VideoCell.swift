
//
//  VideoCell.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.


import SwiftUI

struct VideoCellView: View {
    let video: Video

    var body: some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: video.thumbnail_url)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 400)
                    .clipped()
                    .cornerRadius(12)
            } placeholder: {
                Color.gray.opacity(0.3)
                    .frame(height: 300)
                    .cornerRadius(12)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title ?? "No title")
                    .font(.headline)
                Text("@\(video.author ?? "unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
    }
}
