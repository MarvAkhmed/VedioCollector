//
//  Video.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import SwiftUI

struct Video: Identifiable {
    let id: Int
    let title: String?
    let thumbnail_url: String
    let author: String?
    let location: String?
    let views: Int?
    let duration: Int?
    let video_url: String? 
}
