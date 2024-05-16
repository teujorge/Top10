//
//  Top10App.swift
//  Top10
//
//  Created by Matheus Jorge on 5/14/24.
//

import SwiftUI
import Lottie

@main
struct Top10App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: Utils

// Function to vibrate the device
func vibrate() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
}
