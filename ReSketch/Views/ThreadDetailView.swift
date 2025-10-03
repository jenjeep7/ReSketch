//
//  ThreadDetailView.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI

struct ThreadDetailView: View {
    let thread: Thread
    @StateObject private var submissionManager = SubmissionManager()
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showCanvas = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Original Image
                VStack(alignment: .leading, spacing: 12) {
                    Text("Original")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    AsyncImage(url: URL(string: thread.originalImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay { ProgressView() }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(thread.title)
                            .font(.title2.bold())
                        
                        if let description = thread.description {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack {
                            Label(thread.creatorUsername, systemImage: "person.circle.fill")
                            Spacer()
                            Label(thread.createdAt.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                // Re-Sketch Button
                Button {
                    showCanvas = true
                } label: {
                    Label("Create Your Re-Sketch", systemImage: "pencil.and.outline")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                }
                
                // Submissions Grid
                if !submissionManager.submissions.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Re-Sketches (\(submissionManager.submissions.count))")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 12),
                            GridItem(.flexible(), spacing: 12)
                        ], spacing: 12) {
                            ForEach(submissionManager.submissions) { submission in
                                SubmissionCard(submission: submission)
                            }
                        }
                        .padding(.horizontal)
                    }
                } else if submissionManager.isLoading {
                    ProgressView("Loading re-sketches...")
                        .padding()
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "paintbrush.pointed")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                        Text("Be the first to re-sketch!")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 40)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Thread")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showCanvas) {
            ReSketchCanvasView(
                thread: thread,
                onSubmit: { image, drawing in
                    Task {
                        if let user = authManager.user {
                            _ = try await submissionManager.submitReSketch(
                                threadID: thread.id,
                                artistID: user.id,
                                artistUsername: user.username,
                                image: image,
                                drawingData: drawing
                            )
                            await submissionManager.fetchSubmissions(for: thread.id)
                        }
                    }
                    showCanvas = false
                }
            )
        }
        .task {
            await submissionManager.fetchSubmissions(for: thread.id)
        }
    }
}

struct SubmissionCard: View {
    let submission: Submission
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: submission.thumbnailURL ?? submission.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay { ProgressView() }
            }
            .frame(height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(submission.artistUsername)
                    .font(.caption.bold())
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    Label("\(submission.likeCount)", systemImage: "heart")
                    Label("\(submission.commentCount)", systemImage: "bubble")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
    }
}
