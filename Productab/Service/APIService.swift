//
//  VideoPlayerManager.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import Combine
import SwiftUI
//
//// MARK: - Debug API Service
//class APIService {
//    static let shared = APIService()
//    private init() {}
//    
//    private let baseURL = "https://interesnoitochka.ru/api/v1"
//    
//    func fetchVideos(offset: Int = 0, limit: Int = 10) -> AnyPublisher<[Video], Error> {
//        let urlStr = "\(baseURL)/videos/recommendations?offset=\(offset)&limit=\(limit)&category=shorts&date_filter_type=created&sort_by=date_created&sort_order=desc"
//        
//        print("🔗 Fetching from: \(urlStr)")
//        
//        guard let url = URL(string: urlStr) else {
//            print("❌ Invalid URL")
//            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        request.timeoutInterval = 30
//        
//        return URLSession.shared.dataTaskPublisher(for: request)
//            .tryMap { output in
//                let response = output.response as? HTTPURLResponse
//                print("📡 Response status: \(response?.statusCode ?? -1)")
//                
//                // Print raw response for debugging
//                if let rawString = String(data: output.data, encoding: .utf8) {
//                    print("📄 Raw response: \(rawString.prefix(500))...")
//                }
//                
//                guard let httpResponse = response else {
//                    throw URLError(.badServerResponse)
//                }
//                
//                guard (200...299).contains(httpResponse.statusCode) else {
//                    print("❌ HTTP Error: \(httpResponse.statusCode)")
//                    throw URLError(.badServerResponse)
//                }
//                
//                return output.data
//            }
//            .decode(type: VideoResponse.self, decoder: JSONDecoder())
//            .map { response in
//                print("✅ Successfully decoded \(response.items.count) videos")
//                return response.items.map { Video(from: $0) }
//            }
//            .catch { error -> AnyPublisher<[Video], Error> in
//                print("❌ Decoding error: \(error)")
//                print("❌ Error details: \(error.localizedDescription)")
//                
//                // Fallback to mock data
//                print("🔄 Falling back to mock data")
//                return Just(APIService.getMockVideos())
//                    .setFailureType(to: Error.self)
//                    .eraseToAnyPublisher()
//            }
//            .eraseToAnyPublisher()
//    }
//    
//    // Enhanced mock data with all fields
//    static func getMockVideos() -> [Video] {
//        return [
//            Video(
//                id: 1,
//                title: "Beautiful Mountain Sunrise",
//                description: "Watching the sunrise from the top of the Swiss Alps",
//                thumbnail_url: "https://picsum.photos/400/700",
//                video_url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
//                author: "NatureExplorer",
//                location: "Swiss Alps, Switzerland",
//                tags: ["nature", "mountains", "sunrise", "adventure", "travel"],
//                likes: 1250,
//                views: 15000,
//                comments: 89,
//                duration: 45,
//                author_avatar_url: "https://picsum.photos/100/100"
//            ),
//            Video(
//                id: 2,
//                title: "Italian Pasta Cooking Tutorial",
//                description: "Learn to make authentic carbonara pasta from scratch",
//                thumbnail_url: "https://picsum.photos/400/700",
//                video_url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
//                author: "ChefMarco",
//                location: "Rome, Italy",
//                tags: ["cooking", "pasta", "italian", "food", "recipe"],
//                likes: 890,
//                views: 8900,
//                comments: 45,
//                duration: 120,
//                author_avatar_url: "https://picsum.photos/100/100"
//            ),
//            Video(
//                id: 3,
//                title: "Urban Exploration Adventure",
//                description: "Exploring abandoned places in downtown Tokyo",
//                thumbnail_url: "https://picsum.photos/400/700",
//                video_url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
//                author: "UrbanAdventurer",
//                location: "Tokyo, Japan",
//                tags: ["urban", "exploration", "abandoned", "adventure", "city"],
//                likes: 2300,
//                views: 45000,
//                comments: 156,
//                duration: 67,
//                author_avatar_url: "https://picsum.photos/100/100"
//            ),
//            Video(
//                id: 4,
//                title: "Beach Sunset Meditation",
//                description: "Peaceful meditation session during sunset at the beach",
//                thumbnail_url: "https://picsum.photos/400/700",
//                video_url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
//                author: "MindfulTraveler",
//                location: "Bali, Indonesia",
//                tags: ["meditation", "beach", "sunset", "wellness", "peaceful"],
//                likes: 3400,
//                views: 78000,
//                comments: 234,
//                duration: 89,
//                author_avatar_url: "https://picsum.photos/100/100"
//            )
//        ]
//    }
//}


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
}
