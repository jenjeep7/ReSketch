//
//  DrawingScreen.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI
import PencilKit
import PhotosUI
import AVFoundation

struct DrawingScreen: View {
    // Canvas state
    @State private var drawing = PKDrawing()
    @State private var fingerDrawing = true
    @State private var tool: PKTool = PKInkingTool(.pen, color: .label, width: 6)

    // Optional background (a "seed" image)
    @State private var seedImage: UIImage?
    @State private var showPhotoPicker = false
    @State private var photoSelection: PhotosPickerItem?
    @State private var showShare = false
    @State private var renderImage: UIImage?

    var body: some View {
        ZStack {
            // Seed image behind the canvas if present
            if let img = seedImage {
                GeometryReader { geo in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width, maxHeight: geo.size.height)
                        .clipped()
                }
                .ignoresSafeArea() // make the artwork full-bleed
            }

            // PencilKit canvas on top
            PencilCanvasRepresentable(
                drawing: $drawing,
                isFingerDrawingEnabled: $fingerDrawing,
                activeTool: $tool
            )
            .ignoresSafeArea() // draw edge-to-edge
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarLeading) {
                Button {
                    showPhotoPicker = true
                } label: {
                    Label("Seed", systemImage: "photo")
                }

                Button {
                    // Clear canvas (keep seed)
                    drawing = PKDrawing()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
            }

            ToolbarItemGroup(placement: .topBarTrailing) {
                // Pencil-only toggle (Palm rejection: Pencil only)
                Toggle(isOn: $fingerDrawing) {
                    Image(systemName: fingerDrawing ? "hand.draw" : "pencil.and.outline")
                }
                .toggleStyle(.button)

                Menu {
                    Button("Pen") { tool = PKInkingTool(.pen, color: .label, width: 6) }
                    Button("Marker") { tool = PKInkingTool(.marker, color: .label, width: 10) }
                    Button("Pencil") { tool = PKInkingTool(.pencil, color: .label, width: 4) }
                    Divider()
                    Button("Eraser (Vector)") { tool = PKEraserTool(.vector) }
                    Button("Eraser (Bitmap)") { tool = PKEraserTool(.bitmap) }
                } label: {
                    Image(systemName: "paintbrush.pointed")
                }

                Button {
                    let img = exportComposite()
                    renderImage = img
                    showShare = true
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                Button {
                    let img = exportComposite()
                    UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
            }
        }
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $photoSelection,
            matching: .images,
            photoLibrary: .shared()
        )
        .onChange(of: photoSelection) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    seedImage = image
                }
            }
        }
        .sheet(isPresented: $showShare) {
            if let img = renderImage {
                ShareSheet(activityItems: [img])
                    .ignoresSafeArea()
            }
        }
        .navigationTitle("Canvas")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Merge seed + strokes into one image sized to screen
    private func exportComposite() -> UIImage {
        let screen = UIScreen.main.bounds.size
        let format = UIGraphicsImageRendererFormat()
        format.scale = UIScreen.main.scale
        let renderer = UIGraphicsImageRenderer(size: screen, format: format)
        return renderer.image { ctx in
            UIColor.systemBackground.setFill()
            ctx.fill(CGRect(origin: .zero, size: screen))

            if let img = seedImage {
                let rect = AVMakeRect(aspectRatio: img.size, insideRect: CGRect(origin: .zero, size: screen))
                img.draw(in: rect)
            }

            let strokes = drawing.image(from: CGRect(origin: .zero, size: screen),
                                        scale: UIScreen.main.scale)
            strokes.draw(in: CGRect(origin: .zero, size: screen))
        }
    }
}

// Simple ShareSheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    NavigationStack {
        DrawingScreen()
    }
}
