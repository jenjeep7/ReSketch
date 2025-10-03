# ReSketch - Collaborative Drawing Platform

A social platform for artists to share original drawings and create re-sketches (variations) of each other's work. Built with SwiftUI, PencilKit, and Firebase.

## 🎨 Features

### Core Features
- **User Authentication** - Email/password sign up and sign in
- **Create Threads** - Upload or draw original artwork to start a thread
- **Browse Feed** - Discover original artwork from other artists
- **Re-Sketch** - Create your own version of someone's artwork with PencilKit
- **View Submissions** - See all re-sketches for any thread
- **Reference Mode** - Draw with the original artwork visible at adjustable opacity

### Drawing Features
- Full-screen PencilKit canvas with Apple Pencil support
- Pressure, tilt, and low-latency drawing
- System PKToolPicker (brushes, markers, pencils, erasers)
- Palm rejection toggle
- Undo/Redo support
- Save drawing data for replay (future feature)

## 🏗️ Architecture

### Tech Stack
- **Frontend**: SwiftUI (iOS 16+)
- **Drawing**: PencilKit
- **Backend**: Firebase
  - Authentication
  - Firestore (database)
  - Cloud Storage (images)
- **Language**: Swift 5.9+

### Data Models

**User**
```swift
- id: String (Firebase UID)
- username: String (unique)
- email: String
- displayName: String
- profileImageURL: String?
- threadCount: Int
- submissionCount: Int
```

**Thread** (Original Artwork)
```swift
- id: String
- creatorID: String
- creatorUsername: String
- title: String
- description: String?
- originalImageURL: String
- thumbnailURL: String?
- submissionCount: Int
- tags: [String]
- createdAt: Date
```

**Submission** (Re-Sketch)
```swift
- id: String
- threadID: String
- artistID: String
- artistUsername: String
- imageURL: String
- thumbnailURL: String?
- likeCount: Int
- commentCount: Int
- drawingDataURL: String? (for replay)
- createdAt: Date
```

### Project Structure
```
ReSketch/
├── Models/
│   ├── User.swift
│   ├── Thread.swift
│   └── Submission.swift
├── Services/
│   ├── AuthenticationManager.swift
│   ├── ThreadManager.swift
│   └── SubmissionManager.swift
├── Views/
│   ├── AuthenticationView.swift
│   ├── FeedView.swift
│   ├── ThreadDetailView.swift
│   ├── CreateThreadView.swift
│   ├── CreateArtworkCanvas.swift
│   ├── ReSketchCanvasView.swift
│   └── DrawingScreen.swift (original demo)
├── PencilCanvasRepresentable.swift
├── ContentView.swift
├── ReSketchApp.swift
└── Assets.xcassets/
```

## 🚀 Getting Started

### Prerequisites
- macOS with Xcode 15.0+
- iOS 16.0+ device or simulator
- Firebase account (free tier works)
- Apple Developer account (for device testing)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/jenjeep7/ReSketch.git
   cd ReSketch
   ```

2. **Install Firebase SDK**
   - Open `ReSketch.xcodeproj` in Xcode
   - Go to File > Add Package Dependencies
   - Add: `https://github.com/firebase/firebase-ios-sdk`
   - Select: FirebaseAuth, FirebaseFirestore, FirebaseStorage

3. **Configure Firebase**
   - Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Email/Password authentication
   - Create Firestore database and deploy rules from `firestore.rules`
   - Enable Cloud Storage and deploy rules from `storage.rules`
   - Create Firestore index for submissions (see below)
   - Download `GoogleService-Info.plist` from Firebase Console
   - **IMPORTANT**: Place it in the `ReSketch/` folder (same level as `ReSketchApp.swift`)
   - **⚠️ NEVER commit this file to git** - it contains sensitive API keys

4. **Create Firestore Index**
   - Go to Firestore → Indexes
   - Create composite index for `submissions` collection:
     - `threadID` (Ascending)
     - `createdAt` (Descending)
   - Or click the auto-generated link when the app requests it

5. **Update Bundle Identifier**
   - Select the ReSketch target
   - Update Bundle Identifier to match your Firebase project (e.g., `com.resketch.app`)
   - Select your development team

6. **Build and Run**
   - Select an iPad simulator or device (recommended)
   - Press ⌘R to build and run

### ⚠️ Security Note

The `GoogleService-Info.plist` file is **excluded from version control** via `.gitignore` because it contains sensitive API keys. 

**If you accidentally committed it:**
1. Remove from git: `git rm --cached ReSketch/GoogleService-Info.plist`
2. Commit the removal: `git commit -m "Remove sensitive config"`
3. **Rotate your API keys** in Firebase Console
4. Download a new `GoogleService-Info.plist`

## 📱 User Flow

1. **Sign Up / Sign In**
   - Create account with email, username, display name, password
   - Or sign in with existing credentials

2. **Browse Feed**
   - View all original artwork threads
   - See thread titles, creators, re-sketch counts
   - Tap a thread to view details

3. **View Thread**
   - See the original artwork full-size
   - Browse all re-sketches in a grid
   - Tap "Create Your Re-Sketch" to draw

4. **Create Re-Sketch**
   - Original artwork appears as reference (adjustable opacity)
   - Draw your version using PencilKit tools
   - Toggle reference visibility
   - Submit when complete

5. **Create New Thread**
   - Choose to draw new artwork or upload from photos
   - Add title, description, and tags
   - Create thread to share with community

## 🎯 Roadmap

### Phase 1 - MVP (Current)
- ✅ User authentication
- ✅ Create threads (upload/draw)
- ✅ Browse feed
- ✅ Create re-sketches
- ✅ View submissions

### Phase 2 - Social Features
- [ ] Like/favorite submissions
- [ ] Comments on submissions
- [ ] User profiles
- [ ] Follow/followers system
- [ ] Notifications

### Phase 3 - Discovery
- [ ] Search by tags/username
- [ ] Trending threads
- [ ] Categories/collections
- [ ] Explore page

### Phase 4 - Advanced Drawing
- [ ] Time-lapse replay of drawings
- [ ] Custom brushes
- [ ] Layer support
- [ ] Export to multiple formats (PNG, PDF, etc.)

### Phase 5 - Moderation & Safety
- [ ] Content moderation (Cloud Functions)
- [ ] Report system
- [ ] Image SafeSearch integration
- [ ] Block/mute users

### Phase 6 - Monetization
- [ ] Premium brushes/tools
- [ ] Art challenges with prizes
- [ ] Artist marketplace
- [ ] Ad-free experience

## 🔐 Security & Privacy

- All data is stored in Firebase with security rules
- Users can only edit their own content
- Images are stored in Cloud Storage with access control
- Passwords are managed by Firebase Auth (never stored locally)

## 📝 Contributing

This is a personal project, but suggestions and feedback are welcome! Feel free to:
- Open issues for bugs or feature requests
- Submit pull requests for improvements
- Share your ideas for new features

## 📄 License

MIT License - See LICENSE file for details

## 🙏 Acknowledgments

- Apple's PencilKit for amazing drawing capabilities
- Firebase for backend infrastructure
- The iOS developer community

---

Built with ❤️ using SwiftUI, PencilKit, and Firebase

**Created by:** Jennifer Nelson  
**GitHub:** [@jenjeep7](https://github.com/jenjeep7)
