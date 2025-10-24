//  VideoPlayerCellView.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import Foundation
import SwiftUI
import AVKit

struct VideoPlayerCellView: View {

    @ObservedObject private var vm: VideoPlayerCellViewModel
    let onBack: () -> Void
    
    init(video: Video, player: AVPlayer, isMuted: Binding<Bool>, isActive: Bool, onBack: @escaping () -> Void) {
        _vm = ObservedObject(wrappedValue: VideoPlayerCellViewModel(
            video: video,
            player: player,
            isMuted: isMuted.wrappedValue,
            isActive: isActive
        ))
        self.onBack = onBack
    }
    var body: some View {
        ZStack {
            buildVideoPlayer()
        
            VStack {
                buildUpperSection()
                    .padding(.horizontal)
                    .padding(.top, 130)
                
                Spacer()
                
                // Bottom section (stats and interactions)
                VStack(alignment: .leading, spacing: 16) {
                    friendsWatching()
                    totalWatching()
                    locationIcon()
                    listTags()
                    listWhoReacted()
                    commentsSectionBuilder()
                        .padding(.bottom, 70)
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // ← ADD THIS
        .ignoresSafeArea() // ← ADD THIS
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func buildVideoPlayer() -> some View {
        ZStack {
            VideoPlayerViewWrapper(player: vm.player)
                  .disabled(true)
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
                  .ignoresSafeArea()
                  .onChange(of: vm.isActive) { oldValue, newValue in
                      vm.handleActiveStateChange(isActive: newValue)
                  }
                  .onAppear {
                      vm.handleActiveStateChange(isActive: vm.isActive)
                  }
                
            
            VStack {
                HStack {
                    // Back icon
                    Button(action: {
                        onBack()
                    }) {
                        Image(uiImage: Icons.backIcon ?? UIImage())
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .padding(.top, 60)
                            .padding(.leading, 20)
                    }
                    
                    Spacer()
                    
                    // Share icon
                    Image(uiImage: Icons.shareIcon ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(.top, 60)
                        .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    private func buildUpperSection() -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
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
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func friendsWatching() -> some View {
        HStack {
            Image(uiImage: Icons.friendsWatching ?? UIImage())
                .frame(width: 16, height: 16)
                .foregroundColor(.white)
            
            // Split the text to apply different fonts
            Text("Друзья смотрят: ")
                .font(Fonts.robotoRegular11) // Regular 400
                .foregroundColor(.white)
            
            Text("@dasha @anna @pavel")
                .font(Fonts.robotoBold11) // Bold 700
                .foregroundColor(.white)
                .underline() // Underline decoration
        }
    }

    @ViewBuilder
    private func totalWatching() -> some View {
        HStack {
            Image(uiImage: Icons.allPeopleWatching ?? UIImage())
                .frame(width: 16, height: 16)
                .foregroundColor(.white)
            Text("15k смотрят эфир")
                .font(Fonts.robotoRegular11) // Regular 400
                .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private func locationIcon() -> some View {
        HStack(spacing: 4) {
            Image(uiImage: Icons.whereIcon ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            
            Text("RAMEN")
                .font(Fonts.robotoBold11)
                .foregroundColor(.white)
            
            Image(uiImage: Icons.upArrowIcon ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
                .padding(.leading, 5)
                .padding(.trailing, 5)
            Image(uiImage: Icons.vidioIcon ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 16, height: 16)
            
            Text("12")
                .font(Fonts.robotoBold11)
                .foregroundColor(.white)
        }
    }
    
    @ViewBuilder
    private func listTags() -> some View {
        let tags = vm.video.tags
        
        HStack(spacing: 12) {
            ForEach(tags.prefix(3), id: \.self) { tag in
                Text("#\(tag)")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.white)
            }
        }
    }
    @ViewBuilder
    private func listWhoReacted() -> some View {
        HStack(spacing: 8) {
            vm.metricView(icon: Icons.firstReact, value: vm.video.views)
        
            let likesValue = (vm.video.likes ?? 0) > 0 ? (vm.video.likes ?? 0) : 100000
            vm.metricView(icon: Icons.secondReact, value: likesValue)
            
            if (vm.video.comments ?? 0) > 0 {
                vm.metricView(icon: Icons.thirdReact, value: vm.video.comments ?? 0)
            }
            
            let shareCount = vm.video.views / 10
            if shareCount > 0 {
                vm.metricView(icon: Icons.forthReact, value: shareCount)
            }
            
            let fifthMetric = vm.video.views / 10
            if fifthMetric > 0 {
                vm.metricView(icon: Icons.fifthReact, value: fifthMetric)
            }
        }
    }



    @ViewBuilder
    private func commentsSectionBuilder() -> some View {
        ZStack(alignment: .trailing) {
            TextField("", text: $vm.commentText)
                .font(.system(size: 14))
                .foregroundColor(.white)
                .padding(12)
                .padding(.trailing, 40)
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    HStack {
                        if vm.commentText.isEmpty {
                            Text("Добавить комментарий")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                                .padding(.leading, 12)
                        }
                        Spacer()
                    }
                )
            Button(action: {
                vm.commentText = ""
            }) {
                Image("paper-airplane")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(.blue)
                    .padding(8)
            }
            .padding(.trailing, 8)
        }
    }
}


struct VideoPlayerViewWrapper: UIViewControllerRepresentable {
    
    
    let player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        controller.videoGravity = .resizeAspectFill
        return controller
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player = player
    }
}
