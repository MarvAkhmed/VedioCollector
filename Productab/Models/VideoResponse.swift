//
//  VideoResponse.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import Foundation

struct VideoResponse: Codable {
    let total: Int
    let offset: Int
    let limit: Int
    let count: Int
    let items: [VideoItem]
}

struct VideoItem: Identifiable, Codable {
    var id: Int { video_id }
    
    let video_id: Int
    let title: String?
    let preview_image: String?
    let post_image: String?
    let channel_id: Int?
    let channel_name: String?
    let channel_avatar: String?
    let numbers_views: Int?
    let duration_sec: Int?
    let free: Bool?
    let vertical: Bool?
    let seo_url: String?
    let date_publication: String?
    let draft: Bool?
    let time_not_reg: Int?
    let time_not_pay: Int?
    let has_access: Bool?
    let content_type: String?
    let latitude: Double?
    let longitude: Double?
    let location_text: String?
    let playlist_id: Int?
}
