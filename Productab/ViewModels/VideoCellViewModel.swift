//
//  VideoCellViewModel.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import Combine
import Foundation
import SwiftUI

class VideoCellViewModel: ObservableObject {
    let video: Video
    @Published var isContentLoaded = false
    @Published var isLoading = false
    
    private var loadedResources: Set<String> = []
    
    init(video: Video) {
        self.video = video
    }
    
    // MARK: - Cell Lifecycle Methods
    
    func onCellAppeared() {
        guard !isContentLoaded && !isLoading else { return }
        
        isLoading = true
        loadHeavyResources { [weak self] in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.isContentLoaded = true
            }
        }
    }
    
    func onCellDisappeared() {
        unloadHeavyResources()
        isContentLoaded = false
        isLoading = false
    }
    
    // MARK: - Resource Management
    
    private func loadHeavyResources(completion: @escaping () -> Void) {
        loadedResources.insert("thumbnail")
        loadedResources.insert("avatar")
        
        DispatchQueue.global(qos: .utility).async {
            Thread.sleep(forTimeInterval: 0.05)
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func unloadHeavyResources() {
        // Release heavy resources when cell disappears
        
        // Clear image caches for this video
        if let thumbnailUrl = URL(string: video.thumbnailUrl) {
            ImageCache.shared.remove(forKey: thumbnailUrl.absoluteString)
        }
        
        if let avatarUrl = video.authorAvatarUrl, let url = URL(string: avatarUrl) {
            ImageCache.shared.remove(forKey: url.absoluteString)
        }
        
        loadedResources.removeAll()
    }
}
