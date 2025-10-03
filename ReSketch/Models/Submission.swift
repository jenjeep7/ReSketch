//
//  Submission.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import Foundation

struct Submission: Identifiable, Codable {
    var id: String // Firestore document ID
    var threadID: String // Parent thread
    var artistID: String // User who created this re-sketch
    var artistUsername: String
    var imageURL: String // Cloud Storage URL
    var thumbnailURL: String?
    var createdAt: Date
    var likeCount: Int
    var commentCount: Int
    var drawingDataURL: String? // Optional: PKDrawing data for replay/edit
    
    enum CodingKeys: String, CodingKey {
        case id
        case threadID
        case artistID
        case artistUsername
        case imageURL
        case thumbnailURL
        case createdAt
        case likeCount
        case commentCount
        case drawingDataURL
    }
}
