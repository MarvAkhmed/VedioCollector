import SwiftUI
import Combine

struct VideoCell: View {
    @ObservedObject private var vm: VideoCellViewModel
    @State private var showContent = false
    
    init(vm: VideoCellViewModel) {
        self.vm = vm
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if showContent && vm.isContentLoaded {
                buildOptimizedThumbnail()
            } else {
                buildPlaceholder()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                buildOptimizedUpperSection()
                Spacer()
                VStack(alignment: .leading, spacing: 8) {
                    listTags()
                    reactionIcons()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            vm.onCellAppeared()
            // Small delay to ensure resources are loaded
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showContent = true
            }
        }
        .onDisappear {
            vm.onCellDisappeared()
            showContent = false
        }
    }
    
    @ViewBuilder
    private func buildPlaceholder() -> some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 500)
            .overlay(
                ProgressView()
                    .tint(.white)
            )
            .cornerRadius(22)
    }
    
    @ViewBuilder
    private func buildOptimizedThumbnail() -> some View {
        CachedAsyncImage(
            url: URL(string: vm.video.thumbnailUrl),
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 500)
                    .clipped()
                    .cornerRadius(22)
            },
            placeholder: {
                buildPlaceholder()
            }
        )
    }
    
    @ViewBuilder
    private func buildOptimizedUpperSection() -> some View {
        HStack(alignment: .top, spacing: 12) {
            buildOptimizedAvatar()
            
            // Text content
            VStack(alignment: .leading, spacing: 6) {
                buildAuthorName()
                buildDescription()
                buildFriendsTags()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
    }
    
    @ViewBuilder
    private func buildOptimizedAvatar() -> some View {
        ZStack {
            if showContent && vm.isContentLoaded {
                CachedAsyncImage(
                    url: URL(string: vm.video.authorAvatarUrl ?? ""),
                    content: { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    },
                    placeholder: {
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
                                    .stroke(Color.white, lineWidth: 2)
                            )
                    }
                )
            } else {
                // Show placeholder for avatar too
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 80, height: 100)
                    .overlay(
                        ProgressView()
                            .tint(.white)
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
    }
    
    @ViewBuilder
    private func buildAuthorName() -> some View {
        HStack(spacing: 4) {
            Text("@\(vm.video.author)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private func buildDescription() -> some View {
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
    }
    
    @ViewBuilder
    private func buildFriendsTags() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Гуляю по пляжу с друзьями @anna")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
            
            Text("@oleg @dasha")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
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
                    Text("\(likes.formatNumber())")
                        .font(.caption)
                }
                .foregroundColor(.white)
            }
            
            let views = vm.video.views
            HStack(spacing: 4) {
                Image(systemName: "eye.fill")
                    .font(.caption)
                Text("\(views.formatNumber()))")
                    .font(.caption)
            }
            .foregroundColor(.white)
        }
    }
}
