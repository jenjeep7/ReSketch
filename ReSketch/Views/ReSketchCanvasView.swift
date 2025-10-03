//
//  ReSketchCanvasView.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI
import PencilKit
import AVFoundation

struct ReSketchCanvasView: View {
    let thread: Thread
    let onSubmit: (UIImage, PKDrawing) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var drawing = PKDrawing()
    @State private var tool: PKTool = PKInkingTool(.pen, color: .label, width: 6)
    @State private var fingerDrawing = true
    @State private var seedImage: UIImage?
    @State private var showOriginal = true
    @State private var originalOpacity: Double = 0.5
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Original image as reference
                if showOriginal, let img = seedImage {
                    GeometryReader { geo in
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                            .opacity(originalOpacity)
                            .clipped()
                    }
                    .ignoresSafeArea()
                }
                
                // Drawing canvas
                PencilCanvasRepresentable(
                    drawing: $drawing,
                    isFingerDrawingEnabled: $fingerDrawing,
                    activeTool: $tool
                )
                .ignoresSafeArea()
            }
            .navigationTitle("Re-Sketch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    
                    Button {
                        drawing = PKDrawing()
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    .disabled(drawing.bounds.isEmpty)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Toggle(isOn: $showOriginal) {
                            Label("Show Original", systemImage: showOriginal ? "eye.fill" : "eye.slash")
                        }
                        
                        if showOriginal {
                            Section("Opacity") {
                                ForEach([0.25, 0.5, 0.75, 1.0], id: \.self) { opacity in
                                    Button("\(Int(opacity * 100))%") {
                                        originalOpacity = opacity
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Reference", systemImage: "photo")
                    }
                    
                    Toggle(isOn: $fingerDrawing) {
                        Image(systemName: fingerDrawing ? "hand.draw" : "pencil.and.outline")
                    }
                    .toggleStyle(.button)
                    
                    Button {
                        let image = exportComposite()
                        onSubmit(image, drawing)
                    } label: {
                        Label("Submit", systemImage: "paperplane.fill")
                    }
                    .disabled(drawing.bounds.isEmpty)
                }
            }
            .task {
                await loadOriginalImage()
            }
        }
    }
    
    private func loadOriginalImage() async {
        guard let url = URL(string: thread.originalImageURL) else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                seedImage = image
            }
        } catch {
            print("Failed to load original image: \(error)")
        }
    }
    
    private func exportComposite() -> UIImage {
        let screen = UIScreen.main.bounds.size
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: screen, format: format)
        
        return renderer.image { ctx in
            UIColor.systemBackground.setFill()
            ctx.fill(CGRect(origin: .zero, size: screen))
            
            let strokes = drawing.image(from: CGRect(origin: .zero, size: screen), scale: UIScreen.main.scale)
            strokes.draw(in: CGRect(origin: .zero, size: screen))
        }
    }
}
