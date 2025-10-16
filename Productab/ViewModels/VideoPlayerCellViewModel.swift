//
//  VideoPlayerCellViewModel.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import SwiftUI
import AVKit
import Combine

class VideoPlayerCellViewModel: ObservableObject {
    
    @Published var isPlaying = false
    @Published var commentText = ""
    @Published var showComments = false
    
    let video: Video
    let player: AVPlayer
    var isMuted: Bool
    var isActive: Bool
    
    init(video: Video, player: AVPlayer, isMuted: Bool, isActive: Bool) {
        self.video = video
        self.player = player
        self.isMuted = isMuted
        self.isActive = isActive
    }
    
    // Helper function to format numbers
    func formatNumber(_ number: Int) -> String {
        if number >= 1000000 {
            return String(format: "%.1fM", Double(number) / 1000000.0)
        } else if number >= 1000 {
            return String(format: "%.0fK", Double(number) / 1000.0) 
        } else {
            return "\(number)"
        }
    }
    
    func handleActiveStateChange(isActive: Bool) {
        if isActive {
            player.isMuted = isMuted
            player.play()
            isPlaying = true
        } else {
            player.pause()
            isPlaying = false
        }
    }
    
    func togglePlayPause() {
        if player.rate > 0 {
            player.pause()
            isPlaying = false
        } else {
            player.play()
            isPlaying = true
        }
    }
    
    func metricView(icon: UIImage?, value: Int) -> some View {
        HStack(spacing: 6) {
            Image(uiImage: icon ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
            Text(formatNumber(value))
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .fixedSize()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(red: 0, green: 0, blue: 0, opacity: 0.3))
        .cornerRadius(20)
    }
}
