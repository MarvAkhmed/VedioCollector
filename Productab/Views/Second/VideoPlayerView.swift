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
    @State private var players: [Int: AVPlayer] = [:] // LAZY loading
    @State private var isMuted = false
    @Environment(\.dismiss) var dismiss
    
    @State private var offset: CGFloat = 0
    @State private var isDragging = false
    @State private var dragTranslation: CGFloat = 0
    
    // Track which videos are prepared
    @State private var preparedIndices = Set<Int>()
    
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
                        onBack: { dismiss() }
                    )
                    .frame(width: proxy.size.width, height: itemHeight)
                    .offset(y: CGFloat(index) * itemHeight - offset)
                    .onAppear {
                        // Preload adjacent videos only
                        preloadVideoIfNeeded(at: index)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .ignoresSafeArea()
            .gesture(dragGesture(itemHeight: itemHeight, maxOffset: maxOffset))
            .onAppear {
                offset = CGFloat(currentIndex) * itemHeight
                // Only prepare initial video + neighbors
                prepareInitialVideos()
            }
        }
        .ignoresSafeArea()
        .onChange(of: currentIndex) { oldValue, newValue in
            handleVideoTransition(from: oldValue, to: newValue)
        }
        .onDisappear {
            cleanupAllPlayers()
        }
        .navigationBarHidden(true)
    }
    
    // MARK: - Smart Video Management
    
    private func prepareInitialVideos() {
        // Only prepare current video + next one for smooth scrolling
        prepareVideo(at: currentIndex)
        prepareVideo(at: currentIndex + 1)
    }
    
    private func preloadVideoIfNeeded(at index: Int) {
        // Only preload if within 2 videos of current position
        guard abs(index - currentIndex) <= 2 else { return }
        prepareVideo(at: index)
    }
    
    private func prepareVideo(at index: Int) {
        guard index >= 0 && index < videos.count else { return }
        guard !preparedIndices.contains(index) else { return }
        
        let video = videos[index]
        guard let url = URL(string: video.videoUrl) else { return }
        
        let player = AVPlayer(url: url)
        player.isMuted = true // Start muted to save battery
        player.pause() // Don't auto-play
        
        // Lightweight preparation - don't buffer aggressively
        player.automaticallyWaitsToMinimizeStalling = true
        
        players[index] = player
        preparedIndices.insert(index)
        
        print("🎬 Prepared video at index \(index)")
    }
    
    private func getOrCreatePlayer(for index: Int) -> AVPlayer {
        if let existingPlayer = players[index] {
            return existingPlayer
        }
        
        // Create placeholder player that will be replaced when needed
        let placeholder = AVPlayer()
        placeholder.pause()
        return placeholder
    }
    
    private func handleVideoTransition(from oldIndex: Int, to newIndex: Int) {
        // Pause old video
        if let oldPlayer = players[oldIndex] {
            oldPlayer.pause()
        }
        
        // Play new video
        if let player = players[newIndex] {
            player.isMuted = isMuted
            player.seek(to: .zero)
            player.play()
            
            // Prepare next videos for smooth scrolling
            prepareVideo(at: newIndex + 1)
            prepareVideo(at: newIndex + 2)
        } else {
            // Emergency preparation if not already prepared
            prepareVideo(at: newIndex)
        }
        
        // Cleanup distant videos
        cleanupDistantVideos(from: newIndex)
    }
    
    private func cleanupDistantVideos(from currentIndex: Int) {
        // Clean up videos more than 3 away from current to save memory
        let indicesToRemove = players.keys.filter { index in
            abs(index - currentIndex) > 3
        }
        
        for index in indicesToRemove {
            if let player = players.removeValue(forKey: index) {
                player.pause()
                player.replaceCurrentItem(with: nil)
                preparedIndices.remove(index)
                print("🗑️ Cleaned up video at index \(index)")
            }
        }
    }
    
    private func cleanupAllPlayers() {
        for (_, player) in players {
            player.pause()
            player.replaceCurrentItem(with: nil)
        }
        players.removeAll()
        preparedIndices.removeAll()
        print("🧹 Cleaned up all video players")
    }
    
    // MARK: - Gesture (optimized)
    
    private func dragGesture(itemHeight: CGFloat, maxOffset: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                isDragging = true
                dragTranslation = value.translation.height
                
                let newOffset = CGFloat(currentIndex) * itemHeight - dragTranslation
                offset = min(max(0, newOffset), maxOffset)
            }
            .onEnded { value in
                isDragging = false
                let predictedEndOffset = CGFloat(currentIndex) * itemHeight - value.predictedEndTranslation.height
                
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
    }
}
