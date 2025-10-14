//
//  VideoPlayerManager.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import Foundation
import Combine

class APIService {
    static let shared = APIService()
    private init() {}

    func fetchVideos(offset: Int = 0, limit: Int = 10) -> AnyPublisher<[Video], Error> {
        let urlStr = "https://interesnoitochka.ru/api/v1/videos/recommendations?offset=\(offset)&limit=\(limit)&category=shorts&date_filter_type=created&sort_by=date_created&sort_order=desc"
        guard let url = URL(string: urlStr) else { return Fail(error: URLError(.badURL)).eraseToAnyPublisher() }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: VideoResponse.self, decoder: JSONDecoder())
            .map { response in
                response.items.map { item in
                    Video(
                        id: item.video_id,
                        title: item.title,
                        thumbnail_url: item.preview_image ?? "",
                        author: item.channel_name,
                        location: item.location_text,
                        views: item.numbers_views,
                        duration: item.duration_sec,
                        video_url: nil
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
