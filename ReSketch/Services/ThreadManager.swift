//
//  ThreadManager.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit

@MainActor
class ThreadManager: ObservableObject {
    @Published var threads: [Thread] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Fetch all threads for the feed
    func fetchThreads(limit: Int = 50) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let snapshot = try await db.collection("threads")
                .order(by: "createdAt", descending: true)
                .limit(to: limit)
                .getDocuments()
            
            threads = snapshot.documents.compactMap { doc in
                try? doc.data(as: Thread.self)
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Create a new thread with original artwork
    func createThread(
        creatorID: String,
        creatorUsername: String,
        title: String,
        description: String?,
        image: UIImage,
        tags: [String]
    ) async throws -> Thread {
        isLoading = true
        errorMessage = nil
        
        do {
            // Upload image to Storage
            let imageURL = try await uploadImage(image: image, path: "threads")
            let thumbnailURL = try await uploadThumbnail(image: image, path: "thumbnails/threads")
            
            // Create thread document
            let threadRef = db.collection("threads").document()
            let thread = Thread(
                id: threadRef.documentID,
                creatorID: creatorID,
                creatorUsername: creatorUsername,
                title: title,
                description: description,
                originalImageURL: imageURL,
                thumbnailURL: thumbnailURL,
                createdAt: Date(),
                submissionCount: 0,
                tags: tags
            )
            
            try threadRef.setData(from: thread)
            
            // Update user's thread count
            try await db.collection("users").document(creatorID).updateData([
                "threadCount": FieldValue.increment(Int64(1))
            ])
            
            isLoading = false
            return thread
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    // Upload full-size image
    private func uploadImage(image: UIImage, path: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let ref = storage.reference().child("\(path)/\(filename)")
        
        // Debug: Check if we're authenticated
        if let currentUser = Auth.auth().currentUser {
            print("✅ Uploading as authenticated user: \(currentUser.uid)")
        } else {
            print("❌ WARNING: No authenticated user found!")
        }
        
        _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
    // Upload thumbnail
    private func uploadThumbnail(image: UIImage, path: String) async throws -> String {
        let thumbnailSize = CGSize(width: 400, height: 400)
        guard let thumbnail = image.resized(to: thumbnailSize),
              let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create thumbnail"])
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let ref = storage.reference().child("\(path)/\(filename)")
        
        _ = try await ref.putDataAsync(thumbnailData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}

// Helper extension for image resizing
extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
