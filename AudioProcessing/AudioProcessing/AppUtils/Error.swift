//
//  Error.swift
//  AudioProcessing
//
//  Created by Vishak on 01/03/25.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
}
