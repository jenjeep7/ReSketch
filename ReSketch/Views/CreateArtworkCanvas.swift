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
    @State private var selectedColor: Color = .black
    @State private var penWidth: CGFloat = 6
    @State private var tool: PKInkingTool.InkType = .pen
    @State private var fingerDrawing = true
    
    // Preset colors
    let presetColors: [Color] = [
        .black, .white, .gray,
        .red, .orange, .yellow,
        .green, .mint, .cyan,
        .blue, .indigo, .purple,
        .pink, .brown
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Drawing Canvas
                ZStack {
                    Color.white
                    
                    PencilCanvasRepresentable(
                        drawing: $drawing,
                        isFingerDrawingEnabled: $fingerDrawing,
                        activeTool: .constant(PKInkingTool(tool, color: UIColor(selectedColor), width: penWidth))
                    )
                }
                
                // Drawing Tools Bar
                VStack(spacing: 12) {
                    // Color Palette
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(presetColors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Circle()
                                            .strokeBorder(selectedColor == color ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                    .shadow(color: .black.opacity(0.2), radius: 2)
                                    .onTapGesture {
                                        selectedColor = color
                                    }
                            }
                            
                            // Custom color picker
                            ColorPicker("", selection: $selectedColor)
                                .labelsHidden()
                                .frame(width: 36, height: 36)
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 50)
                    
                    // Tool controls
                    HStack(spacing: 20) {
                        // Tool type selector
                        Picker("Tool", selection: $tool) {
                            Image(systemName: "pencil").tag(PKInkingTool.InkType.pen)
                            Image(systemName: "paintbrush.fill").tag(PKInkingTool.InkType.marker)
                            Image(systemName: "pencil.tip").tag(PKInkingTool.InkType.pencil)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                        
                        Spacer()
                        
                        // Pen width slider
                        HStack {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 8))
                            Slider(value: $penWidth, in: 1...20)
                                .frame(width: 100)
                            Image(systemName: "circle.fill")
                                .font(.system(size: 16))
                        }
                        
                        Spacer()
                        
                        // Finger drawing toggle
                        Toggle(isOn: $fingerDrawing) {
                            Image(systemName: fingerDrawing ? "hand.draw" : "hand.draw.fill")
                        }
                        .toggleStyle(.button)
                        
                        // Clear button
                        Button {
                            drawing = PKDrawing()
                        } label: {
                            Image(systemName: "trash")
                        }
                        .disabled(drawing.bounds.isEmpty)
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
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
