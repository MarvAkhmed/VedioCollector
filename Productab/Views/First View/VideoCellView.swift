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
            
            
            
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            buildProfileAndUsername()
                            buildAuthorDetails()
                        }
                    }
                    .padding()
                    Spacer()
                }
                Spacer()
            }
            .frame(height: 500)
            
            // Bottom-right content (Reactions)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    reactionIcons()  // Reactions on the RIGHT
                }
                .padding()
            }
            .frame(height: 500)
        }
    }
    
    // MARK: - views
    @ViewBuilder
    private func buildProfileAndUsername() -> some View {
        HStack {
            AsyncImage(url: URL(string: video.authorAvatarUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 130)
                    .clipShape(Rectangle())
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
            
        }
    }
    
    @ViewBuilder
    private func buildAuthorDetails() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(video.author)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            if let description = video.description {
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            
            Text(video.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(2)
        }
        .padding(10)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.black.opacity(0.7), .black.opacity(0.5)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
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
    
    @ViewBuilder
    private func reactionIcons() -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 6) {
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
                } else {
                    Text("No tags found")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .italic()
                }
                
                if let location = video.location {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption)
                        Text(location)
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.8))
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "location.slash")
                            .font(.caption)
                        Text("Location not available")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .italic()
                }
                
            }
        }.padding(.trailing, 90)
  
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
#Preview {
    let ved = Video(id: 1, title: "", thumbnailUrl: "", videoUrl: "", author: "", views: 2, duration: 3)
    VideoCell(video: ved)
}
