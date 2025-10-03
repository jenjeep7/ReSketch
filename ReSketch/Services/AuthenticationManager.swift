//
//  AuthenticationManager.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthenticationManager: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let firebaseUser = auth.currentUser {
            Task {
                await fetchUser(uid: firebaseUser.uid)
            }
        }
    }
    
    func signUp(email: String, password: String, username: String, displayName: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Create Firebase Auth user first
            let result = try await auth.createUser(withEmail: email, password: password)
            
            // Now check if username is available (authenticated now)
            let usernameQuery = try await db.collection("users")
                .whereField("username", isEqualTo: username)
                .getDocuments()
            
            if !usernameQuery.documents.isEmpty {
                // Username taken - delete the auth user we just created
                try await result.user.delete()
                throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Username already taken"])
            }
            
            // Create user profile in Firestore
            let newUser = User(
                id: result.user.uid,
                username: username,
                email: email,
                displayName: displayName,
                profileImageURL: nil,
                createdAt: Date(),
                threadCount: 0,
                submissionCount: 0
            )
            
            try await saveUser(newUser)
            self.user = newUser
            self.isAuthenticated = true
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            await fetchUser(uid: result.user.uid)
            
        } catch {
            errorMessage = error.localizedDescription
            throw error
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try auth.signOut()
            user = nil
            isAuthenticated = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func fetchUser(uid: String) async {
        do {
            let document = try await db.collection("users").document(uid).getDocument()
            if let userData = try? document.data(as: User.self) {
                self.user = userData
                self.isAuthenticated = true
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func saveUser(_ user: User) async throws {
        try db.collection("users").document(user.id).setData(from: user)
    }
}
