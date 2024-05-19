//
//  Top10App.swift
//  Top10
//
//  Created by Matheus Jorge on 5/14/24.
//

import SwiftUI

@main
struct Top10App: App {
    
    @StateObject
    private var entitlementManager: EntitlementManager
    
    @StateObject
    private var subscriptionsManager: SubscriptionsManager
    
    @State private var isAppReady = false
    
    init() {
        let entitlementManager = EntitlementManager()
        let subscriptionsManager = SubscriptionsManager(entitlementManager: entitlementManager)
        
        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._subscriptionsManager = StateObject(wrappedValue: subscriptionsManager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(isAppReady: $isAppReady)
                .environmentObject(entitlementManager)
                .environmentObject(subscriptionsManager)
                .task {
                    Task {
                        print("Updating purchased products")
                        await subscriptionsManager.updatePurchasedProducts()
                        DispatchQueue.main.async {
                            withAnimation { isAppReady = true }
                        }
                        print("App is ready")
                    }
                }
        }
    }
}

// MARK: Utils

struct WithManagers<Content: View>: View {
    @StateObject private var entitlementManager: EntitlementManager
    @StateObject private var subscriptionsManager: SubscriptionsManager
    
    private let content: Content
    
    init(userTier: UserTier = .pro, fundTransactions: [FundTransaction]? = nil, @ViewBuilder content: () -> Content) {
        let entitlementManager = EntitlementManager()
        let subscriptionsManager = SubscriptionsManager(entitlementManager: entitlementManager)
        
        entitlementManager.userTier = userTier
        entitlementManager.fundTransactions = fundTransactions ??  [
            FundTransaction(amount: 10.0, timestamp: Date().addingTimeInterval(-30 * 24 * 60 * 60)),
            FundTransaction(amount: 5.0, timestamp: Date().addingTimeInterval(-15 * 24 * 60 * 60))
        ]
        
        self._entitlementManager = StateObject(wrappedValue: entitlementManager)
        self._subscriptionsManager = StateObject(wrappedValue: subscriptionsManager)
        self.content = content()
    }
    
    var body: some View {
        content
            .environmentObject(entitlementManager)
            .environmentObject(subscriptionsManager)
    }
}


// Function to vibrate the device
func vibrate() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
}
