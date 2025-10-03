//
//  FeedView.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var threadManager = ThreadManager()
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var showCreateThread = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(threadManager.threads) { thread in
                        NavigationLink(destination: ThreadDetailView(thread: thread)) {
                            ThreadCard(thread: thread)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("ReSketch")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        authManager.signOut()
                    } label: {
                        Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateThread = true
                    } label: {
                        Label("Create", systemImage: "plus.circle.fill")
                    }
                }
            }
            .refreshable {
                await threadManager.fetchThreads()
            }
            .sheet(isPresented: $showCreateThread) {
                CreateThreadView()
            }
            .task {
                if threadManager.threads.isEmpty {
                    await threadManager.fetchThreads()
                }
            }
        }
    }
}

struct ThreadCard: View {
    let thread: Thread
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail Image
            AsyncImage(url: URL(string: thread.thumbnailURL ?? thread.originalImageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        ProgressView()
                    }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Thread Info
            VStack(alignment: .leading, spacing: 4) {
                Text(thread.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                HStack {
                    Label(thread.creatorUsername, systemImage: "person.circle.fill")
                        .font(.caption)
                    
                    Spacer()
                    
                    Label("\(thread.submissionCount)", systemImage: "pencil.and.outline")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
                
                if !thread.tags.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(thread.tags, id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

#Preview {
    FeedView()
        .environmentObject(AuthenticationManager())
}
