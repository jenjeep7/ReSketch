# Firebase Setup Checklist

## ✅ Setup Progress

### 1. Firebase Project Setup
- [ ] Created Firebase project
- [ ] Added iOS app to Firebase project
- [ ] Downloaded GoogleService-Info.plist
- [ ] Added GoogleService-Info.plist to Xcode project

### 2. Xcode Configuration
- [ ] Added Firebase SDK via Swift Package Manager
  - [ ] FirebaseAuth
  - [ ] FirebaseFirestore
  - [ ] FirebaseStorage
- [ ] Updated Bundle Identifier to match Firebase
- [ ] Selected Development Team in Signing & Capabilities

### 3. Firebase Services
- [ ] Enabled Authentication (Email/Password)
- [ ] Created Firestore Database
- [ ] Published Firestore security rules (from firestore.rules)
- [ ] Enabled Cloud Storage
- [ ] Published Storage security rules (from storage.rules)

### 4. Test the App
- [ ] Build succeeds in Xcode
- [ ] App launches on simulator/device
- [ ] Can create account (sign up)
- [ ] Can sign in
- [ ] Check Firebase Console → Authentication → Users (should see test user)

---

## Quick Reference

**Bundle Identifier:** `com.yourcompany.ReSketch` (update in Xcode if different)

**Firebase SDK Version:** 11.0.0+

**Minimum iOS Version:** 16.0

**Required Packages:**
```
https://github.com/firebase/firebase-ios-sdk
- FirebaseAuth
- FirebaseFirestore  
- FirebaseStorage
```

**Security Rules Files:**
- `firestore.rules` - Firestore Database rules
- `storage.rules` - Cloud Storage rules

---

## Troubleshooting

### "GoogleService-Info.plist not found"
- Make sure the file is in the ReSketch folder (same level as source files)
- Check it's added to the ReSketch target (select file → File Inspector → Target Membership)

### "No such module 'FirebaseAuth'"
- Clean build folder: Cmd+Shift+K
- Close and reopen Xcode
- Verify packages are added: File → Packages → Resolve Package Versions

### "Permission denied" errors
- Make sure Firestore and Storage rules are published
- Check that Email/Password auth is enabled
- Verify user is signed in before accessing data

### Build errors
- Make sure all three Firebase packages are selected
- Check that minimum deployment target is iOS 16.0
- Try cleaning derived data: Xcode → Preferences → Locations → Derived Data → Delete

---

## Next Steps After Setup

1. **Test Authentication**
   - Run app on simulator
   - Sign up with test email
   - Verify user appears in Firebase Console

2. **Test Thread Creation**
   - Create a test thread with drawing/photo
   - Check Firestore Console for thread document
   - Check Storage Console for uploaded image

3. **Test Re-Sketch**
   - Open a thread
   - Create a re-sketch
   - Verify submission appears in Firestore
   - Check image uploaded to Storage

4. **Optional: Add Test Data**
   - Create a few test threads
   - Add some re-sketches
   - Test the feed and browsing experience

---

## Firebase Console URLs

**Main Console:** https://console.firebase.google.com/

**Your Project:**
- Authentication: https://console.firebase.google.com/project/YOUR_PROJECT_ID/authentication/users
- Firestore: https://console.firebase.google.com/project/YOUR_PROJECT_ID/firestore/databases
- Storage: https://console.firebase.google.com/project/YOUR_PROJECT_ID/storage

Replace `YOUR_PROJECT_ID` with your actual Firebase project ID.
