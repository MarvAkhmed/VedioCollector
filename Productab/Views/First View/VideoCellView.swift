//
//  VideoCellView.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.

import SwiftUI
import Combine

struct VideoCell: View {
    
    @ObservedObject private var vm: VideoCellViewModel
    
    init(vm: VideoCellViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            buildThumbnail()
            
            VStack(alignment: .leading, spacing: 0) {
                buildUpperSection()
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    listTags()
                    reactionIcons()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
    }
    
    @ViewBuilder
    private func buildThumbnail() -> some View {
        AsyncImage(url: URL(string: vm.video.thumbnailUrl)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 500)
                .clipped()
                .cornerRadius(22)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 500)
                .overlay(
                    ProgressView()
                        .tint(.white)
                )
        }
    }
    
    @ViewBuilder
    private func buildUpperSection() -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Profile picture with live indicator on the stroke
            ZStack {
                // Profile image - RECTANGLE
                AsyncImage(url: URL(string: vm.video.authorAvatarUrl ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 2) // White stroke
                        )
                } placeholder: {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 80, height: 100)
                        .overlay(
                            Text(vm.video.author.prefix(1).uppercased())
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.blue)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 2) // White stroke
                        )
                }
                
                VStack {
                    Spacer()
                    Image(uiImage: Icons.liveIcon ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80 * 0.3, height: 20)
                        .background(Color.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .offset(y: 12)
                }
            }
            .frame(width: 80, height: 100)
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                // Author name
                HStack(spacing: 4) {
                    Text("@\(vm.video.author)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Description
                if let description = vm.video.description {
                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("Водные просторы также впечатляют своей красотой. Вода успокаивает.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                // Friends tags
                VStack(alignment: .leading, spacing: 2) {
                    Text("Гуляю по пляжу с друзьями @anna")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                    
                    Text("@oleg @dasha")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private func listTags() -> some View {
        let tags = vm.video.tags
        
        HStack(spacing: 8) {
            ForEach(tags.prefix(3), id: \.self) { tag in
                Text("#\(tag)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
            }
        }
    }
    
    @ViewBuilder
    private func reactionIcons() -> some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(uiImage: Icons.currentLocaionIcon ?? UIImage())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                    .foregroundColor(.white)
                
                if let location = vm.video.location {
                    Text(location)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                } else {
                    Text("Россия, Сочи")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            if let likes = vm.video.likes {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                    Text("\(vm.formatNumber(likes))")
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
            
            let views = vm.video.views
            HStack(spacing: 4) {
                Image(systemName: "eye.fill")
                    .font(.caption)
                Text("\(vm.formatNumber(views))")
                    .font(.caption)
            }
            .foregroundColor(.white)
        }
    }
}
