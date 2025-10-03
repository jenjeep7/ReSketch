# Firebase Setup Instructions

## 1. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard
4. Enable Google Analytics (optional)

## 2. Add iOS App to Firebase

1. In Firebase Console, click the iOS+ icon
2. Enter your iOS bundle ID: `com.yourcompany.ReSketch` (or your custom bundle ID)
3. Download the `GoogleService-Info.plist` file
4. Add it to your Xcode project (drag into the ReSketch folder)
   - Make sure "Copy items if needed" is checked
   - Select the ReSketch target

## 3. Install Firebase SDK

### Using Swift Package Manager (Recommended)

1. In Xcode, go to **File > Add Package Dependencies**
2. Enter the Firebase SDK URL: `https://github.com/firebase/firebase-ios-sdk`
3. Select version: **10.0.0** or later
4. Select these libraries:
   - ✅ FirebaseAuth
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
5. Click "Add Package"

## 4. Enable Firebase Services

### Authentication
1. In Firebase Console, go to **Authentication > Sign-in method**
2. Enable **Email/Password** provider
3. Click Save

### Firestore Database
1. Go to **Firestore Database**
2. Click "Create database"
3. Start in **production mode** (we'll add security rules later)
4. Choose a location closest to your users
5. Click Enable

### Cloud Storage
1. Go to **Storage**
2. Click "Get started"
3. Start in **production mode**
4. Use default location
5. Click Done

## 5. Firestore Security Rules

Replace the default rules with these:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Threads collection (original artwork)
    match /threads/{threadId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.creatorID;
      allow update: if request.auth != null;
    }
    
    // Submissions collection (re-sketches)
    match /submissions/{submissionId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == request.resource.data.artistID;
      allow update: if request.auth != null && request.auth.uid == resource.data.artistID;
    }
  }
}
```

## 6. Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /threads/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /submissions/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /thumbnails/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    
    match /drawings/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 7. Update Bundle Identifier (if needed)

1. In Xcode, select the ReSketch project
2. Select the ReSketch target
3. Go to **Signing & Capabilities**
4. Update the **Bundle Identifier** to match what you entered in Firebase
5. Select your development team

## 8. Test the Connection

1. Build and run the app
2. Sign up with a test account
3. Check Firebase Console to see if the user appears in Authentication
4. Try creating a thread and check Firestore for the document

## Troubleshooting

- **"GoogleService-Info.plist not found"**: Make sure the file is in your Xcode project and added to the target
- **"No bundle URL present"**: Clean build folder (Cmd+Shift+K) and rebuild
- **"Permission denied"**: Check Firestore security rules are published
- **Images not uploading**: Verify Storage security rules are set correctly

## Next Steps

Once Firebase is configured, you can:
- Add user profiles
- Implement likes/comments on submissions
- Add push notifications
- Enable social features
- Add content moderation
- Implement search and filtering
