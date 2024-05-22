//
//  ContentView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/14/24.
//

import SwiftUI
import StoreKit

struct ContentView: View {
    
    @EnvironmentObject var userData: UserData
    @State private var showLaunchAnimation = true
    
    // Async timer to handle the launch animation
    func handleLaunchAnimation() {
        Task {
            // Hide launch animation after animation completes and app is ready
            try await Task.sleep(nanoseconds: 2_000_000_000)
            DispatchQueue.main.async {
                withAnimation { showLaunchAnimation = false }
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Main content displayed after animation and data loading
            TabView {
                CategoriesView()
                    .tabItem() {
                        Image(systemName: "house")
                        Text("Home")
                    }
                GenerateCategoryView()
                    .tabItem() {
                        Image(systemName: "wand.and.stars")
                        Text("Generate")
                    }
                ProfileView()
                    .tabItem() {
                        Image(systemName: "person")
                        Text("Profile")
                    }
            }
            
            // App Logo Animation
            GeometryReader { geometry in
                ZStack {
                    Color(.black)
                        .ignoresSafeArea()
                    
                    LottieView(
                        name: LottieAnimations.logoAnimation,
                        loopMode: .playOnce,
                        animationSpeed: 2
                    )
                    .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                }
            }
            .opacity(showLaunchAnimation ? 1 : 0)
            .animation(.easeIn, value: showLaunchAnimation)
        }
        .onAppear {
            handleLaunchAnimation()
        }
        .subscriptionStatusTask(for: subGroupID) { taskState in
            guard let statuses = taskState.value else {return }
            
            for status in statuses {
                do {
                    let productID = try status.transaction.payloadValue.productID
                    print("Product ID: \(productID)")
                    
                    var possibleUserTier: UserTier {
                        switch productID {
                        case "me.mjorge.topten.sub.pro":
                            return .pro
                        case "me.mjorge.topten.sub.premium":
                            return .premium
                        default:
                            return .none
                        }
                    }
                    print("Possible User Tier: \(possibleUserTier)")
                    
                    switch status.state {
                    case .subscribed:
                        print("subscribed")
                        userData.tier = possibleUserTier
                        print("User Tier: \(userData.tier)")
                    case .expired:
                        print("expired")
                        userData.tier = .none
                    case .inBillingRetryPeriod:
                        print("inBillingRetryPeriod")
                        userData.tier = .none
                    case .inGracePeriod:
                        print("inGracePeriod")
                        userData.tier = .none
                    case .revoked:
                        print("revoked")
                        userData.tier = .none
                    default:
                        print("default")
                        userData.tier = .none
                    }
                }
                catch {
                    print("Error: \(error)")
                }
            }
        }
        
    }
}

// MARK: Preview

#Preview {
    ContentView()
}
