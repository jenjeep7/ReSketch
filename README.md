# ReSketch

A collaborative drawing app built with SwiftUI and PencilKit for iOS.

## Features

- **Full-screen PencilKit canvas** with Apple Pencil support (pressure, tilt, and low-latency drawing)
- **System PKToolPicker** with brushes, markers, pencils, erasers, colors, and sizes
- **Import seed photos** from your photo library to draw over
- **Undo/Redo** support (two-finger tap gesture or through the tool picker)
- **Save to Photos** - Export your drawings as images
- **Share** your artwork via the system share sheet
- **Palm rejection** toggle (Pencil-only or finger+Pencil modes)

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- iPad or iPhone (optimized for iPad with Apple Pencil)

## Getting Started

1. Clone this repository
2. Open `ReSketch.xcodeproj` in Xcode
3. Select your target device (iPad recommended for best experience)
4. Build and run (⌘R)

## Privacy Permissions

The app requests the following permissions:

- **Photo Library (Save)** - To save your drawings to Photos
- **Photo Library (Access)** - To import seed images for drawing
- **Camera** - To capture photos directly (optional feature)

These are configured in the Info.plist automatically through the build settings.

## Architecture

### Key Files

- `ReSketchApp.swift` - App entry point
- `ContentView.swift` - Root navigation container
- `DrawingScreen.swift` - Main canvas screen with toolbar and photo import
- `PencilCanvasRepresentable.swift` - UIKit bridge for PencilKit canvas
- `Assets.xcassets` - App icons and colors

### Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **PencilKit** - Apple's high-performance drawing framework
- **PhotosUI** - Photo picker integration
- **AVFoundation** - Image aspect ratio utilities

## Roadmap

- [ ] Firebase integration for collaborative threads
- [ ] Real-time drawing synchronization
- [ ] Time-lapse replay of drawings
- [ ] Drawing version history
- [ ] User authentication
- [ ] Content moderation
- [ ] iPad split-view UI (thread list + canvas)
- [ ] Export to multiple formats (PNG, PDF, PencilKit data)

## License

MIT License - feel free to use this as a starter for your own projects!

## Contributing

This is an early-stage project. Feel free to open issues or submit pull requests!

---

Built with ❤️ using SwiftUI and PencilKit
