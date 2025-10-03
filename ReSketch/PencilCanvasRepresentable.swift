//
//  PencilCanvasRepresentable.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI
import PencilKit

struct PencilCanvasRepresentable: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    @Binding var isFingerDrawingEnabled: Bool
    @Binding var activeTool: PKTool

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: PencilCanvasRepresentable
        init(_ parent: PencilCanvasRepresentable) { self.parent = parent }
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.backgroundColor = .clear
        canvas.isOpaque = false
        canvas.drawing = drawing
        canvas.drawingPolicy = isFingerDrawingEnabled ? .anyInput : .pencilOnly
        canvas.tool = activeTool
        canvas.delegate = context.coordinator

        // Show the system tool picker (brushes/colors/eraser)
        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }),
           let toolPicker = PKToolPicker.shared(for: window) {
            toolPicker.addObserver(canvas)
            toolPicker.setVisible(true, forFirstResponder: canvas)
            canvas.becomeFirstResponder()
        }
        return canvas
    }

    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        if canvas.drawing != drawing { canvas.drawing = drawing }
        canvas.drawingPolicy = isFingerDrawingEnabled ? .anyInput : .pencilOnly
        if type(of: canvas.tool) != type(of: activeTool) || canvas.tool != activeTool {
            canvas.tool = activeTool
        }
    }
}
