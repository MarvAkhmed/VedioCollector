//
//  VideoCellView.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//
import SwiftUI
import Combine

struct VideoCell: View {
    let video: Video
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Thumbnail
            AsyncImage(url: URL(string: video.thumbnailUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 500)
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 500)
                    .overlay(
                        ProgressView()
                            .tint(.white)
                    )
            }
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black.opacity(0.8)]),
                startPoint: .center,
                endPoint: .bottom
            )
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                
                Text(video.title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                if let description = video.description {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
                
                HStack {
                    AsyncImage(url: URL(string: video.authorAvatarUrl ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.caption)
                            )
                    }
                    
                    Text(video.author)
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Stats
                    HStack(spacing: 12) {
                        if let likes = video.likes {
                            HStack(spacing: 4) {
                                Image(systemName: "heart.fill")
                                    .font(.caption)
                                Text("\(formatNumber(likes))")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                        
                        let views = video.views
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .font(.caption)
                                Text("\(formatNumber(views))")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        
                        
                        if let comments = video.comments {
                            HStack(spacing: 4) {
                                Image(systemName: "message.fill")
                                    .font(.caption)
                                Text("\(formatNumber(comments))")
                                    .font(.caption)
                            }
                            .foregroundColor(.white)
                        }
                    }
                }
                
                // Tags
                if let tags = video.tags, !tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(tags.prefix(5), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // Location
                if let location = video.location {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(location)
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding()
        }
        .frame(height: 500)
    }
    
    private func formatNumber(_ number: Int) -> String {
        if number >= 1000000 {
            return String(format: "%.1fM", Double(number) / 1000000.0)
        } else if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000.0)
        } else {
            return "\(number)"
        }
    }
}
