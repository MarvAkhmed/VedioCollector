
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
        VStack {
            AsyncImage(url: URL(string: video.thumbnail_url)) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
            } placeholder: {
                Color.gray
                    .frame(maxWidth: .infinity)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(video.title ?? "No title")
                    .font(.headline)
                    .lineLimit(2)
                Text("@\(video.author ?? "unknown")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(8)
            .padding([.leading, .trailing, .bottom])
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}
