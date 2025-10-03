//
//  SubmissionManager.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import UIKit
import PencilKit

@MainActor
class SubmissionManager: ObservableObject {
    @Published var submissions: [Submission] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Fetch submissions for a specific thread
    func fetchSubmissions(for threadID: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Fetching submissions for thread: \(threadID)")
            let snapshot = try await db.collection("submissions")
                .whereField("threadID", isEqualTo: threadID)
                .order(by: "createdAt", descending: true)
                .getDocuments()
            
            print("📦 Fetched \(snapshot.documents.count) submission documents")
            
            submissions = snapshot.documents.compactMap { doc in
                try? doc.data(as: Submission.self)
            }
            
            print("✅ Successfully parsed \(submissions.count) submissions")
            
        } catch {
            print("❌ Error fetching submissions: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // Submit a new re-sketch
    func submitReSketch(
        threadID: String,
        artistID: String,
        artistUsername: String,
        image: UIImage,
        drawingData: PKDrawing?
    ) async throws -> Submission {
        isLoading = true
        errorMessage = nil
        
        do {
            // Debug: Check authentication
            if let currentUser = Auth.auth().currentUser {
                print("✅ Submitting re-sketch as authenticated user: \(currentUser.uid)")
            } else {
                print("❌ WARNING: No authenticated user found during submission!")
            }
            
            // Upload image
            print("📤 Uploading submission image...")
            let imageURL = try await uploadImage(image: image, path: "submissions")
            let thumbnailURL = try await uploadThumbnail(image: image, path: "thumbnails/submissions")
            print("✅ Images uploaded successfully")
            
            // Optionally upload drawing data for replay
            var drawingDataURL: String?
            if let drawingData = drawingData {
                drawingDataURL = try await uploadDrawingData(drawingData, path: "drawings")
            }
            
            // Create submission document
            let submissionRef = db.collection("submissions").document()
            let submission = Submission(
                id: submissionRef.documentID,
                threadID: threadID,
                artistID: artistID,
                artistUsername: artistUsername,
                imageURL: imageURL,
                thumbnailURL: thumbnailURL,
                createdAt: Date(),
                likeCount: 0,
                commentCount: 0,
                drawingDataURL: drawingDataURL
            )
            
            try submissionRef.setData(from: submission)
            print("✅ Submission document created with ID: \(submissionRef.documentID)")
            
            // Update thread submission count
            try await db.collection("threads").document(threadID).updateData([
                "submissionCount": FieldValue.increment(Int64(1))
            ])
            print("✅ Thread submission count updated")
            
            // Update user's submission count
            try await db.collection("users").document(artistID).updateData([
                "submissionCount": FieldValue.increment(Int64(1))
            ])
            print("✅ Submission complete! Re-sketch submitted to thread: \(threadID)")
            
            isLoading = false
            return submission
            
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            throw error
        }
    }
    
    private func uploadImage(image: UIImage, path: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image"])
        }
        
        let filename = "\(UUID().uuidString).jpg"
        let ref = storage.reference().child("\(path)/\(filename)")
        
        _ = try await ref.putDataAsync(imageData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
    
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
    
    private func uploadDrawingData(_ drawing: PKDrawing, path: String) async throws -> String {
        let drawingData = drawing.dataRepresentation()
        let filename = "\(UUID().uuidString).pkdrawing"
        let ref = storage.reference().child("\(path)/\(filename)")
        
        _ = try await ref.putDataAsync(drawingData)
        let url = try await ref.downloadURL()
        return url.absoluteString
    }
}
