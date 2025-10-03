//
//  User.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String // Firebase Auth UID
    var username: String
    var email: String
    var displayName: String
    var profileImageURL: String?
    var createdAt: Date
    var threadCount: Int // Number of original threads created
    var submissionCount: Int // Number of re-sketches submitted
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case displayName
        case profileImageURL
        case createdAt
        case threadCount
        case submissionCount
    }
}
