//
//  Video.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

// Video.swift
import Foundation

struct Video: Identifiable, Codable {
    let id: Int
    let title: String?
    let description: String?
    let thumbnail_url: String
    var video_url: String
    let author: String?
    let location: String?
    let tags: [String]?
    let likes: Int?
    let views: Int?
    let comments: Int?
    let duration: Int?
}

// VideoItem.swift
struct VideoItem: Codable {
    let video_id: Int
    let title: String?
    let preview_image: String
    let channel_name: String?
    let numbers_views: Int?
    let duration_sec: Int?
}

// VideoResponse.swift
struct VideoResponse: Codable {
    let items: [VideoItem]
}

