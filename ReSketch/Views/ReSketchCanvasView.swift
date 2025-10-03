//
//  ReSketchCanvasView.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI
import PencilKit

struct ReSketchCanvasView: View {
    let thread: Thread
    let onSubmit: (UIImage, PKDrawing) -> Void
    
    @Environment(\.dismiss) var dismiss
    @State private var drawing = PKDrawing()
    @State private var selectedColor: Color = .black
    @State private var penWidth: CGFloat = 6
    @State private var tool: PKInkingTool.InkType = .pen
    @State private var fingerDrawing = true
    @State private var seedImage: UIImage?
    @State private var showColorPicker = false
    @State private var showReference = true
    
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
                // Reference Image Section (above canvas)
                if showReference {
                    VStack(spacing: 8) {
                        if let img = seedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal)
                        } else {
                            ProgressView()
                                .frame(height: 200)
                        }
                        
                        Text("Reference: \(thread.title)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.bottom, 4)
                    }
                    .background(Color(.systemBackground))
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                Divider()
                
                // Drawing Canvas
                PencilCanvasRepresentable(
                    drawing: $drawing,
                    isFingerDrawingEnabled: $fingerDrawing,
                    activeTool: .constant(PKInkingTool(tool, color: UIColor(selectedColor), width: penWidth))
                )
                
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
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
            .navigationTitle("Re-Sketch")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        drawing = PKDrawing()
                    } label: {
                        Label("Clear", systemImage: "trash")
                    }
                    .disabled(drawing.bounds.isEmpty)
                    
                    Button {
                        withAnimation {
                            showReference.toggle()
                        }
                    } label: {
                        Image(systemName: showReference ? "eye.fill" : "eye.slash")
                    }
                    
                    Toggle(isOn: $fingerDrawing) {
                        Image(systemName: fingerDrawing ? "hand.draw" : "hand.draw.fill")
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
