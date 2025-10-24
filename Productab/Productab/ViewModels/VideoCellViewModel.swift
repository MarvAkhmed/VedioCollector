//
//  VideoCellViewModel.swift
//  Productab
//
//  Created by Marwa Awad on 15.10.2025.
//

import Combine
import Foundation

class VideoCellViewModel: ObservableObject {
    
    let video: Video
    
    init(video: Video) {
        self.video = video
    }
    
    
    func formatNumber(_ number: Int) -> String {
        if number >= 1000000 {
            return String(format: "%.1fM", Double(number) / 1000000.0)
        } else if number >= 1000 {
            return String(format: "%.1fK", Double(number) / 1000.0)
        } else {
            return "\(number)"
        }
    }
}
