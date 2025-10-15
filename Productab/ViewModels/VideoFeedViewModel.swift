//
//  VideoFeedViewModel.swift
//  Productab
//
//  Created by Marwa Awad on 14.10.2025.
//

import Foundation
import Combine

class VideoFeedViewModel: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchVideos() {
        isLoading = true
        errorMessage = nil

        APIService.shared.fetchShortVideos()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] videos in
                self?.videos = videos
            }
            .store(in: &cancellables)
    }
}
