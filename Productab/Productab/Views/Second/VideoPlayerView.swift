//  VideooPlayerView.swift - FIXED CUSTOM VERTICAL PAGING
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import SwiftUI
import AVKit

struct VideooPlayerView: View {
    let videos: [Video]
    @State private var currentIndex: Int
    @State private var players: [AVPlayer] = []
    @State private var isMuted = false
    @Environment(\.dismiss) var dismiss // ADD THIS for back navigation
    
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    @State private var dragTranslation: CGFloat = 0
    
    init(videos: [Video], startIndex: Int = 0) {
        self.videos = videos
        _currentIndex = State(initialValue: startIndex)
    }

    var body: some View {
        GeometryReader { proxy in
            let itemHeight = proxy.size.height
            let maxOffset = CGFloat(videos.count - 1) * itemHeight
            
            ZStack {
                ForEach(Array(videos.enumerated()), id: \.offset) { index, video in
                    VideoPlayerCellView(
                        video: video,
                        player: getOrCreatePlayer(for: index),
                        isMuted: $isMuted,
                        isActive: currentIndex == index,
                        onBack: {
                            dismiss() 
                        }
                    )
                    .frame(width: proxy.size.width, height: itemHeight)
                    .offset(y: CGFloat(index) * itemHeight - offset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // ← CHANGED TO maxWidth/maxHeight
            .clipped()
            .contentShape(Rectangle())
            .ignoresSafeArea() // ← ADDED THIS
            .gesture(
                DragGesture()
                    .onChanged { value in
                        isDragging = true
                        dragTranslation = value.translation.height
                        
                        // Calculate new offset with bounds checking
                        let newOffset = CGFloat(currentIndex) * itemHeight - dragTranslation
                        offset = min(max(0, newOffset), maxOffset)
                    }
                    .onEnded { value in
                        isDragging = false
                        let predictedEndOffset = CGFloat(currentIndex) * itemHeight - value.predictedEndTranslation.height
                        
                        // Determine target index based on drag
                        let targetIndex: Int
                        if abs(value.velocity.height) > 500 {
                            // Quick swipe - follow velocity
                            targetIndex = value.velocity.height < 0 ?
                                min(currentIndex + 1, videos.count - 1) :
                                max(currentIndex - 1, 0)
                        } else {
                            // Slow drag or prediction - use predicted end position
                            let dragDirection = predictedEndOffset < offset ? -1 : 1
                            let currentPosition = offset / itemHeight
                            
                            if abs(dragTranslation) > itemHeight * 0.2 {
                                // Significant drag - move in drag direction
                                targetIndex = min(max(Int(currentPosition.rounded() + CGFloat(dragDirection)), 0), videos.count - 1)
                            } else {
                                // Small drag - snap to nearest
                                targetIndex = Int(currentPosition.rounded())
                            }
                        }
                        
                        // Ensure target index is within bounds
                        let safeTargetIndex = min(max(targetIndex, 0), videos.count - 1)
                        
                        withAnimation(.interactiveSpring(response: 0.4, dampingFraction: 0.8)) {
                            currentIndex = safeTargetIndex
                            offset = CGFloat(safeTargetIndex) * itemHeight
                        }
                        
                        dragTranslation = 0
                    }
            )
            .onAppear {
                offset = CGFloat(currentIndex) * itemHeight
            }
        }
        .ignoresSafeArea() // ← KEEP THIS
        .onChange(of: currentIndex) { oldValue, newValue in
            handleVideoTransition(from: oldValue, to: newValue)
        }
        .onAppear {
            setupPlayers()
            if !players.isEmpty && currentIndex < players.count {
                players[currentIndex].isMuted = isMuted
                players[currentIndex].seek(to: .zero)
                players[currentIndex].play()
            }
        }
        .onDisappear {
            cleanupPlayers()
        }
        .navigationBarHidden(true)
    }
    
    private func handleVideoTransition(from oldIndex: Int, to newIndex: Int) {
        // Pause old video
        if oldIndex < players.count {
            players[oldIndex].pause()
        }
        
        // Play new video
        if newIndex < players.count {
            let player = players[newIndex]
            player.isMuted = isMuted
            player.seek(to: .zero)
            player.play()
        }
    }
    
    private func setupPlayers() {
        players = videos.enumerated().compactMap { index, video in
            guard let url = URL(string: video.videoUrl) else { return nil }
            let player = AVPlayer(url: url)
            player.isMuted = isMuted
            player.actionAtItemEnd = .pause
            player.pause()
            
            // Add observer for video end
            NotificationCenter.default.addObserver(
                forName: .AVPlayerItemDidPlayToEndTime,
                object: player.currentItem,
                queue: .main
            ) { _ in
                player.seek(to: .zero)
                player.play()
            }
            
            return player
        }
    }
    
    private func getOrCreatePlayer(for index: Int) -> AVPlayer {
        guard index < players.count else {
            let player = AVPlayer()
            player.pause()
            return player
        }
        return players[index]
    }
    
    private func cleanupPlayers() {
        // Remove observers
        for player in players {
            if let currentItem = player.currentItem {
                NotificationCenter.default.removeObserver(
                    self,
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: currentItem
                )
            }
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
        players.removeAll()
    }
}
