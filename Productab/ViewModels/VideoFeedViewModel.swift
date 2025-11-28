import Foundation
import Combine

class VideoFeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasMoreVideos = true
    
    // Battery optimization properties
    private var loadingStates: [Int: Bool] = [:] // videoID -> isLoading
    private var visibleVideoIndices = Set<Int>()
    private var loadedVideoIds = Set<Int>()
    
    // Track heavy resources that need unloading
    private var heavyResources: [Int: Any] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private var currentOffset = 0
    private let pageLimit = 10
    
    // MARK: - Initial Data Fetch
    
    func fetchVideosWithTags() {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        currentOffset = 0
        videos.removeAll()
        loadedVideoIds.removeAll()
        heavyResources.removeAll()
        
        // Parallel fetching for better performance
        let tagsPublisher = APIService.shared.fetchAllTags()
        let videosPublisher = APIService.shared.fetchShortVideos(offset: currentOffset, limit: pageLimit)
        
        Publishers.Zip(tagsPublisher, videosPublisher)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error loading videos: \(error)")
                }
            } receiveValue: { [weak self] (tags, videos) in
                guard let self = self else { return }
                
                let enrichedVideos = videos.map { video in
                    self.enrichVideoWithTags(video, allTags: tags)
                }
                
                self.videos = enrichedVideos
                self.hasMoreVideos = videos.count == self.pageLimit
                self.currentOffset += videos.count
                
                print("✅ Loaded initial \(enrichedVideos.count) videos")
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Pagination
    
    func loadMoreVideosIfNeeded() {
        guard !isLoadingMore && hasMoreVideos else { return }
        
        isLoadingMore = true
        
        APIService.shared.fetchAllTags()
            .flatMap { [weak self] tags -> AnyPublisher<[Video], Error> in
                guard let self = self else {
                    return Empty<[Video], Error>().eraseToAnyPublisher()
                }
                
                return APIService.shared.fetchShortVideos(offset: self.currentOffset, limit: self.pageLimit)
                    .map { newVideos in
                        newVideos.map { video in
                            self.enrichVideoWithTags(video, allTags: tags)
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoadingMore = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                    print("Error loading more videos: \(error)")
                }
            } receiveValue: { [weak self] newVideos in
                guard let self = self else { return }
                
                let startIndex = self.videos.count
                self.videos.append(contentsOf: newVideos)
                self.hasMoreVideos = newVideos.count == self.pageLimit
                self.currentOffset += newVideos.count
                
                print("✅ Loaded \(newVideos.count) more videos, total: \(self.videos.count)")
                
                // Auto-load content for newly added visible videos
                for (index, _) in newVideos.enumerated() {
                    let globalIndex = startIndex + index
                    if self.visibleVideoIndices.contains(globalIndex) {
                        self.loadVideoContentIfNeeded(at: globalIndex)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Smart Visibility-Based Loading
    
    func videoDidBecomeVisible(_ index: Int) {
        guard index < videos.count else { return }
        
        visibleVideoIndices.insert(index)
        loadVideoContentIfNeeded(at: index)
        
        // Pre-load next few videos for smooth scrolling
        preloadAdjacentVideos(from: index)
        
        // Auto-load more content when approaching end
        checkAndLoadMoreContent(currentIndex: index)
    }
    
    func videoDidBecomeInvisible(_ index: Int) {
        guard index < videos.count else { return }
        
        visibleVideoIndices.remove(index)
        unloadVideoContentIfNeeded(at: index)
    }
    
    private func loadVideoContentIfNeeded(at index: Int) {
        guard index < videos.count else { return }
        
        let video = videos[index]
        let videoId = video.id
        
        // Skip if already loaded or loading
        if loadedVideoIds.contains(videoId) || isLoadingVideo(video) {
            return
        }
        
        setLoadingState(for: video, isLoading: true)
        
        // Load heavy resources
        loadHeavyResources(for: video, at: index) { [weak self] in
            DispatchQueue.main.async {
                self?.setLoadingState(for: video, isLoading: false)
                self?.loadedVideoIds.insert(videoId)
                print("✅ Loaded heavy resources for video at index \(index)")
            }
        }
    }
    
    private func unloadVideoContentIfNeeded(at index: Int) {
        guard index < videos.count else { return }
        
        let video = videos[index]
        
        // Release heavy resources
        releaseHeavyResources(for: video, at: index)
        
        // Keep the video in the array but mark as unloaded
        loadedVideoIds.remove(video.id)
        loadingStates.removeValue(forKey: video.id)
        
        print("🗑️ Unloaded heavy resources for video at index \(index)")
        
        // Notify to pause any playback
        NotificationCenter.default.post(
            name: .pauseVideoPlayback,
            object: nil,
            userInfo: ["videoId": video.id, "index": index]
        )
    }
    
    // MARK: - Heavy Resource Management
    
    private func loadHeavyResources(for video: Video, at index: Int, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            // Simulate loading heavy resources
            let heavyResource = self?.prepareHeavyResources(for: video)
            
            DispatchQueue.main.async {
                if let resource = heavyResource {
                    self?.heavyResources[index] = resource
                }
                completion()
            }
        }
    }
    
    private func releaseHeavyResources(for video: Video, at index: Int) {
        // Clear image cache for this video
        if let thumbnailUrl = URL(string: video.thumbnailUrl) {
            ImageCache.shared.remove(forKey: thumbnailUrl.absoluteString)
        }
        
        // Clear avatar cache
        if let avatarUrl = video.authorAvatarUrl, let url = URL(string: avatarUrl) {
            ImageCache.shared.remove(forKey: url.absoluteString)
        }
        
        // Release any stored heavy data
        heavyResources.removeValue(forKey: index)
        
        // Clear any video preview data
        NotificationCenter.default.post(
            name: .releaseVideoPreview,
            object: nil,
            userInfo: ["videoId": video.id]
        )
        
        print("🧹 Released heavy resources for video \(video.id)")
    }
    
    private func prepareHeavyResources(for video: Video) -> Any {
        // Simulate preparing heavy resources
        return [
            "thumbnail_data": "high_res_data_\(video.id)",
            "video_metadata": "preloaded_metadata_\(video.id)",
            "layout_cache": "cached_layout_\(video.id)"
        ]
    }
    
    // MARK: - Smart Preloading
    
    private func preloadAdjacentVideos(from index: Int) {
        // Preload 2 videos ahead for smooth scrolling
        let preloadIndices = [index + 1, index + 2]
        
        for preloadIndex in preloadIndices where preloadIndex < videos.count {
            if !visibleVideoIndices.contains(preloadIndex) && !isVideoContentLoaded(videos[preloadIndex]) {
                loadVideoContentIfNeeded(at: preloadIndex)
            }
        }
    }
    
    private func checkAndLoadMoreContent(currentIndex: Int) {
        // Load more videos when user is 3 videos from the end
        let threshold = videos.count - 3
        if currentIndex >= threshold && hasMoreVideos && !isLoadingMore {
            loadMoreVideosIfNeeded()
        }
    }
    
    // MARK: - Helper Methods
    
    private func enrichVideoWithTags(_ video: Video, allTags: [TagItem]) -> Video {
        let randomTags = Array(allTags.shuffled().prefix(Int.random(in: 3...5)))
        let tagStrings = randomTags.map { $0.tag }
        
        return Video(
            id: video.id,
            title: video.title,
            description: video.description,
            thumbnailUrl: video.thumbnailUrl,
            videoUrl: video.videoUrl,
            author: video.author,
            location: video.location,
            tags: tagStrings,
            likes: video.likes,
            views: video.views,
            comments: video.comments,
            duration: video.duration,
            authorAvatarUrl: video.authorAvatarUrl,
            isVertical: video.isVertical,
            isFree: video.isFree
        )
    }
    
    private func isVideoContentLoaded(_ video: Video) -> Bool {
        return loadedVideoIds.contains(video.id)
    }
    
    private func isLoadingVideo(_ video: Video) -> Bool {
        return loadingStates[video.id] ?? false
    }
    
    private func setLoadingState(for video: Video, isLoading: Bool) {
        loadingStates[video.id] = isLoading
    }
    
    // MARK: - Memory Management
    
    func cleanupResources() {
        // Unload ALL videos
        for index in videos.indices {
            unloadVideoContentIfNeeded(at: index)
        }
        
        // Clear all tracking
        visibleVideoIndices.removeAll()
        loadedVideoIds.removeAll()
        loadingStates.removeAll()
        heavyResources.removeAll()
        
        // Cancel network requests
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        // Clear image cache
        ImageCache.shared.clearCache()
        
        print("🧹 Cleaned up all resources")
    }
    
    func reloadContent() {
        cleanupResources()
        fetchVideosWithTags()
    }
    
    deinit {
        cleanupResources()
    }
}

// MARK: - Notifications

extension Notification.Name {
    static let pauseVideoPlayback = Notification.Name("pauseVideoPlayback")
    static let releaseVideoPreview = Notification.Name("releaseVideoPreview")
}
