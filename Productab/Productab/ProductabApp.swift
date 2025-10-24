//
//  ProductabApp.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import SwiftUI




@main
struct ProductabApp: App {
    let vm = VideoFeedViewModel()
    
    var body: some Scene {
        WindowGroup {
            VideoFeedView()
                .environmentObject(vm)
        }
    }
}
