//
//  Track.swift
//  AudioProcessing
//
//  Created by Vishak on 01/03/25.
//

import Foundation

// Response model to match the API structure
struct TrackResponse: Decodable {
    let results: [Track]  // The API returns a "results" key containing track data
}

// Track model
struct Track: Decodable {
    let id: String
    let name: String
    let artistName: String?
    let albumName: String?
    let duration: Int  // ✅ Directly decode as an Int
    let imageURL: URL?  // ✅ Converts image string to a URL
    let audioURL: URL?  // ✅ Converts audio string to a URL

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artistName = "artist_name"
        case albumName = "album_name"
        case duration
        case image = "image"  // Ensure correct mapping
        case audio = "audio"
    }

    // Custom decoding to safely handle optional URLs
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        artistName = try container.decodeIfPresent(String.self, forKey: .artistName)
        albumName = try container.decodeIfPresent(String.self, forKey: .albumName)
        
        // ✅ Decode duration directly as an Int (fixing type mismatch)
        duration = try container.decode(Int.self, forKey: .duration)
        
        // ✅ Convert image URL string
        let imageString = try container.decodeIfPresent(String.self, forKey: .image)
        imageURL = imageString.flatMap(URL.init)
        
        // ✅ Convert audio URL string
        let audioString = try container.decodeIfPresent(String.self, forKey: .audio)
        audioURL = audioString.flatMap(URL.init)
    }

    // Helper function to format duration as "mm:ss"
    var formattedDuration: String {
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
