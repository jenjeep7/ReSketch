//
//  ReSketchApp.swift
//  ReSketch
//
//  Created on 10/3/25.
//

import SwiftUI
import FirebaseCore

@main
struct ReSketchApp: App {
    @StateObject private var authManager = AuthenticationManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}
