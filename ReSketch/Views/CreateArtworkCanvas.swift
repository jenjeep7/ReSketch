//
//  CreateArtworkCanvas.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI
import PencilKit

struct CreateArtworkCanvas: View {
    let onComplete: (UIImage) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var drawing = PKDrawing()
    @State private var tool: PKTool = PKInkingTool(.pen, color: .label, width: 6)
    @State private var fingerDrawing = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                PencilCanvasRepresentable(
                    drawing: $drawing,
                    isFingerDrawingEnabled: $fingerDrawing,
                    activeTool: $tool
                )
                .ignoresSafeArea(edges: .bottom)
            }
            .navigationTitle("Draw Your Artwork")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        let image = exportDrawing()
                        onComplete(image)
                    }
                    .disabled(drawing.bounds.isEmpty)
                }
            }
        }
    }
    
    private func exportDrawing() -> UIImage {
        let bounds = drawing.bounds.isEmpty ? CGRect(x: 0, y: 0, width: 1000, height: 1000) : drawing.bounds
        return drawing.image(from: bounds, scale: UIScreen.main.scale)
    }
}
