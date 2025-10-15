//
//  APIService.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//
//
//  APIService.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import Foundation
import Combine

// MARK: - Correct Response Models based on ACTUAL API response
struct VideoResponse: Codable {
    let items: [VideoItem]
    let total: Int
    let offset: Int
    let limit: Int
    let count: Int
    let filter: Filter
}

struct Filter: Codable {
    let search: String?
    let videoId: Int?
    let category: String
    let channelId: Int?
    let userId: Int?
    let isFree: Bool?
    let authRequired: Bool?
    let datePeriod: String?
    let dateFilterType: String
    let sortBy: String
    let sortOrder: String
    
    enum CodingKeys: String, CodingKey {
        case search
        case videoId = "video_id"
        case category
        case channelId = "channel_id"
        case userId = "user_id"
        case isFree = "is_free"
        case authRequired = "auth_required"
        case datePeriod = "date_period"
        case dateFilterType = "date_filter_type"
        case sortBy = "sort_by"
        case sortOrder = "sort_order"
    }
}

struct VideoItem: Codable {
    // Basic video info (ACTUALLY IN API)
    let videoId: Int
    let title: String
    let previewImage: String?
    let postImage: String?
    
    // Channel info (ACTUALLY IN API)
    let channelId: Int
    let channelName: String
    let channelAvatar: String?
    
    // Video metrics (ACTUALLY IN API)
    let numbersViews: Int
    let durationSec: Int
    
    // Access & format (ACTUALLY IN API)
    let free: Bool
    let vertical: Bool
    
    // Metadata (ACTUALLY IN API)
    let seoUrl: String
    let datePublication: String
    let draft: Bool
    let hasAccess: Bool
    let contentType: String
    
    // Location (exists in API but often null)
    let latitude: Double?
    let longitude: Double?
    let locationText: String?
    
    // Playlist (ACTUALLY IN API)
    let playlistId: Int?
    
    // Fields that are NOT in API - make optional or remove
    let description: String? = nil
    let numbersLikes: Int? = nil  // NOT IN API
    let numbersComments: Int? = nil // NOT IN API
    let tags: [String]? = nil     // NOT IN API
    
    enum CodingKeys: String, CodingKey {
        case videoId = "video_id"
        case title
        case previewImage = "preview_image"
        case postImage = "post_image"
        case channelId = "channel_id"
        case channelName = "channel_name"
        case channelAvatar = "channel_avatar"
        case numbersViews = "numbers_views"
        case durationSec = "duration_sec"
        case free
        case vertical
        case seoUrl = "seo_url"
        case datePublication = "date_publication"
        case draft
        case hasAccess = "has_access"
        case contentType = "content_type"
        case latitude
        case longitude
        case locationText = "location_text"
        case playlistId = "playlist_id"
        // Don't include fields that don't exist in API
    }
}

struct Video: Identifiable {
    let id: Int
    let title: String
    let description: String?
    let thumbnailUrl: String
    let videoUrl: String
    let author: String
    let location: String?
    let tags: [String]?
    let likes: Int?
    let views: Int
    let comments: Int?
    let duration: Int
    let authorAvatarUrl: String?
    let isVertical: Bool
    let isFree: Bool
    
    init(from item: VideoItem) {
        self.id = item.videoId
        self.title = item.title
        self.description = item.description
        self.thumbnailUrl = item.previewImage ?? ""
        self.videoUrl = "https://interesnoitochka.ru/api/v1/videos/video/\(item.videoId)/hls/playlist.m3u8"
        self.author = item.channelName
        self.location = item.locationText
        self.tags = item.tags
        self.likes = item.numbersLikes ?? 0 // Mock data needed
        self.views = item.numbersViews
        self.comments = item.numbersComments ?? 0 // Mock data needed
        self.duration = item.durationSec
        self.authorAvatarUrl = item.channelAvatar
        self.isVertical = item.vertical
        self.isFree = item.free
    }
    
    // Mock initializer with default mock data for missing fields
    init(id: Int, title: String, description: String? = nil, thumbnailUrl: String, videoUrl: String, author: String, location: String? = nil, tags: [String]? = nil, likes: Int? = nil, views: Int, comments: Int? = nil, duration: Int, authorAvatarUrl: String? = nil, isVertical: Bool = true, isFree: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.thumbnailUrl = thumbnailUrl
        self.videoUrl = videoUrl
        self.author = author
        self.location = location
        self.tags = tags ?? ["interesting", "funny"] // Mock tags
        self.likes = likes ?? Int.random(in: 100...5000) // Mock likes
        self.views = views
        self.comments = comments ?? Int.random(in: 5...200) // Mock comments
        self.duration = duration
        self.authorAvatarUrl = authorAvatarUrl
        self.isVertical = isVertical
        self.isFree = isFree
    }
}
