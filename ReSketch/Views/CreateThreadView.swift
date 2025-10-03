//
//  CreateThreadView.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI
import PhotosUI

struct CreateThreadView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @StateObject private var threadManager = ThreadManager()
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showDrawingCanvas = false
    @State private var tagInput = ""
    @State private var tags: [String] = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Artwork") {
                    if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button("Change Image", role: .destructive) {
                            self.imageData = nil
                        }
                    } else {
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            Label("Choose from Photos", systemImage: "photo.on.rectangle")
                        }
                        
                        Button {
                            showDrawingCanvas = true
                        } label: {
                            Label("Draw New Artwork", systemImage: "pencil.and.outline")
                        }
                    }
                }
                
                Section("Details") {
                    TextField("Title", text: $title)
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                            .textInputAutocapitalization(.never)
                        
                        Button("Add") {
                            let trimmed = tagInput.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && !tags.contains(trimmed) {
                                tags.append(trimmed)
                                tagInput = ""
                            }
                        }
                        .disabled(tagInput.isEmpty)
                    }
                    
                    if !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    HStack(spacing: 4) {
                                        Text("#\(tag)")
                                            .font(.caption)
                                        
                                        Button {
                                            tags.removeAll { $0 == tag }
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                        }
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundStyle(.blue)
                                    .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Create Thread")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createThread()
                    }
                    .disabled(!isFormValid || threadManager.isLoading)
                }
            }
            .onChange(of: selectedImage) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .fullScreenCover(isPresented: $showDrawingCanvas) {
                CreateArtworkCanvas { image in
                    if let data = image.jpegData(compressionQuality: 0.9) {
                        imageData = data
                    }
                    showDrawingCanvas = false
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !title.isEmpty && imageData != nil
    }
    
    private func createThread() {
        guard let user = authManager.user,
              let imageData = imageData,
              let image = UIImage(data: imageData) else {
            return
        }
        
        Task {
            do {
                _ = try await threadManager.createThread(
                    creatorID: user.id,
                    creatorUsername: user.username,
                    title: title,
                    description: description.isEmpty ? nil : description,
                    image: image,
                    tags: tags
                )
                dismiss()
            } catch {
                // Handle error
                print("Error creating thread: \(error)")
            }
        }
    }
}

#Preview {
    CreateThreadView()
        .environmentObject(AuthenticationManager())
}
