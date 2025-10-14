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

        guard let url = URL(string: "https://interesnoitochka.ru/api/v1/videos/recommendations?offset=0&limit=10&category=shorts&date_filter_type=created&sort_by=date_created&sort_order=desc") else {
            self.errorMessage = "Invalid URL"
            self.isLoading = false
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: VideoResponse.self, decoder: JSONDecoder())
            .map { response in
                response.items.map { item in
                    Video(
                        id: item.video_id,
                        title: item.title,
                        description: nil,
                        thumbnail_url: item.preview_image,
                        video_url: "https://interesnoitochka.ru/api/v1/videos/video/\(item.video_id)/hls/playlist.m3u8",
                        author: item.channel_name,
                        location: nil,
                        tags: nil,
                        likes: nil,
                        views: item.numbers_views,
                        comments: nil,
                        duration: item.duration_sec
                    )
                }
            }
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
