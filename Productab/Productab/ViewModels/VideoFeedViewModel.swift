//
//  VideoFeedViewModel.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import Foundation
import Combine

class VideoFeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchVideos() {
        isLoading = true
        errorMessage = nil

        APIService.shared.fetchShortVideos()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] videos in
                self?.videos = videos
            }
            .store(in: &cancellables)
    }
}
// MARK: - VideoFeedViewModel Tags Extension
extension VideoFeedViewModel {
    
    // Replace the main fetchVideos to always include tags
    func fetchVideosWithTags() {
        isLoading = true
        errorMessage = nil

        // First fetch all available tags
        APIService.shared.fetchAllTags()
            .flatMap { [weak self] tags -> AnyPublisher<[Video], Error> in
                guard let self = self else {
                    return Empty<[Video], Error>().eraseToAnyPublisher()
                }
                
                // Then fetch videos
                return APIService.shared.fetchShortVideos()
                    .map { videos in
                        // Assign relevant tags to each video
                        return videos.map { video in
                            self.enrichVideoWithTags(video, allTags: tags)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] videos in
                self?.videos = videos
            }
            .store(in: &cancellables)
    }

    // Fixed: Actually create new Video with custom tags
    private func enrichVideoWithTags(_ video: Video, allTags: [TagItem]) -> Video {
        // Always assign 3-5 random tags from the global list
        let randomTags = Array(allTags.shuffled().prefix(Int.random(in: 3...5)))
        let tagStrings = randomTags.map { $0.tag }
        
        // Create new Video with the assigned tags using the new initializer
        return Video(
            id: video.id,
            title: video.title,
            description: video.description,
            thumbnailUrl: video.thumbnailUrl,
            videoUrl: video.videoUrl,
            author: video.author,
            location: video.location,
            tags: tagStrings,  // This replaces the default ["tags", "not", "found"]
            likes: video.likes,
            views: video.views,
            comments: video.comments,
            duration: video.duration,
            authorAvatarUrl: video.authorAvatarUrl,
            isVertical: video.isVertical,
            isFree: video.isFree
        )
    }
}
