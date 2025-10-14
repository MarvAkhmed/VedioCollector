//
//  VideoPlayerManager.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//


import Foundation
import Combine

// APIService.swift
import Foundation
import Combine

class APIService {
    static let shared = APIService()
    private init() {}

    func fetchVideos(offset: Int = 0, limit: Int = 10) -> AnyPublisher<[Video], Error> {
        let urlStr = "https://interesnoitochka.ru/api/v1/videos/recommendations?offset=\(offset)&limit=\(limit)&category=shorts&date_filter_type=created&sort_by=date_created&sort_order=desc"
        guard let url = URL(string: urlStr) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
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
            .eraseToAnyPublisher()
    }
}
