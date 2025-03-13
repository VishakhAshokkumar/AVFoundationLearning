//
//  PlayerViewModel.swift
//  AudioProcessing
//
//  Created by Vishak on 01/03/25.
//

import Foundation

final class PlayerViewModel {
    var tracks: [Track] = []
    var onTracksFetched: (() -> Void)?
    
    func fetchTracks() {
        NetworkManager.shared.fetchTracks { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let tracks):
                    self?.tracks = tracks
                    self?.onTracksFetched?()
                case .failure(let error):
                    print("Error fetching tracks: \(error)")
                }
            }
        }
    }
    
    func track(at index: Int) -> Track? {
        guard index < tracks.count else { return nil }
        return tracks[index]
    }
    
    
}
