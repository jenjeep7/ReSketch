//
//  AuthenticationView.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authManager = AuthenticationManager()
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var displayName = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // App Logo/Title
                VStack(spacing: 8) {
                    Image(systemName: "pencil.and.outline")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("ReSketch")
                        .font(.largeTitle.bold())
                    
                    Text("Reimagine. Redraw. Inspire.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Form Fields
                VStack(spacing: 16) {
                    if isSignUp {
                        TextField("Username", text: $username)
                            .textContentType(.username)
                            .autocapitalization(.none)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Display Name", text: $displayName)
                            .textContentType(.name)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Password", text: $password)
                        .textContentType(isSignUp ? .newPassword : .password)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.horizontal, 32)
                
                // Error Message
                if let error = authManager.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Action Button
                Button {
                    Task {
                        do {
                            if isSignUp {
                                try await authManager.signUp(
                                    email: email,
                                    password: password,
                                    username: username,
                                    displayName: displayName
                                )
                            } else {
                                try await authManager.signIn(email: email, password: password)
                            }
                        } catch {
                            showError = true
                        }
                    }
                } label: {
                    if authManager.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 32)
                .disabled(authManager.isLoading || !isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
                
                // Toggle Sign Up/Sign In
                Button {
                    withAnimation {
                        isSignUp.toggle()
                        authManager.errorMessage = nil
                    }
                } label: {
                    Text(isSignUp ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
        }
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && password.count >= 6 && !username.isEmpty && !displayName.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
}

#Preview {
    AuthenticationView()
}
