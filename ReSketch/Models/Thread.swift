//
//  Thread.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import Foundation

struct Thread: Identifiable, Codable {
    var id: String // Firestore document ID
    var creatorID: String // User ID who created the original
    var creatorUsername: String
    var title: String
    var description: String?
    var originalImageURL: String // Cloud Storage URL
    var thumbnailURL: String? // Smaller version for feed
    var createdAt: Date
    var submissionCount: Int // Number of re-sketches
    var tags: [String] // e.g., ["character", "landscape", "portrait"]
    
    enum CodingKeys: String, CodingKey {
        case id
        case creatorID
        case creatorUsername
        case title
        case description
        case originalImageURL
        case thumbnailURL
        case createdAt
        case submissionCount
        case tags
    }
}
