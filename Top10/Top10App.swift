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
    
    @StateObject
    private var entitlementManager: EntitlementManager
    
    @StateObject
    private var subscriptionsManager: SubscriptionsManager
    
    init() {
        let entitlementManager = EntitlementManager()
        let subscriptionsManager = SubscriptionsManager(entitlementManager: entitlementManager)
        
        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._subscriptionsManager = StateObject(wrappedValue: subscriptionsManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(entitlementManager)
                .environmentObject(subscriptionsManager)
                .task {
                    await subscriptionsManager.updatePurchasedProducts()
                }
        }
    }
}

// MARK: Utils

// Function to vibrate the device
func vibrate() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
}
