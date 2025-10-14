//
//  Video.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import Foundation

struct Video: Identifiable, Codable {
    let id: Int              // maps to video_id
    let title: String?
    let description: String?
    let thumbnail_url: String  // maps to preview_image
    var video_url: String?     // obtained from HLS endpoint
    let author: String?        // channel_name
    let location: String?
    let tags: [String]?
    let likes: Int?
    let views: Int?            // numbers_views
    let comments: Int?
    let duration: Int?         // duration_sec
}
