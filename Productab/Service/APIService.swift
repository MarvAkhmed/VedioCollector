//
//  VideoPlayerManager.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import Combine
import SwiftUI

// MARK: - API Service
class APIService {
    static let shared = APIService()
    private let baseURL = "https://interesnoitochka.ru/api/v1"
    
    func fetchShortVideos(offset: Int = 0, limit: Int = 10) -> AnyPublisher<[Video], Error> {
        let urlString = "\(baseURL)/videos/recommendations?offset=\(offset)&limit=\(limit)&category=shorts&date_filter_type=created&sort_by=date_created&sort_order=desc"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: VideoResponse.self, decoder: JSONDecoder())
            .map { response in
                response.items.map { Video(from: $0) }
            }
            .eraseToAnyPublisher()
    }
    
    func fetchAllTags() -> AnyPublisher<[TagItem], Error> {
        let urlString = "\(baseURL)/tags"
        
        guard let url = URL(string: urlString) else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TagResponse.self, decoder: JSONDecoder())
            .map { $0.items }
            .eraseToAnyPublisher()
    }
}

