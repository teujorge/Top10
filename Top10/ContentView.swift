//
//  ContentView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/14/24.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @Binding var isAppReady: Bool
    @State private var showLaunchAnimation = true
    @State private var animationComplete = false
    
    // Async timer to handle the launch animation
    func handleLaunchAnimation() {
        Task {
            // Hide launch animation after animation completes and app is ready
            try await Task.sleep(nanoseconds: 2_000_000_000)
            DispatchQueue.main.async {
                if isAppReady {
                    withAnimation { showLaunchAnimation = false }
                }
                else {
                    animationComplete = true
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Main content displayed after animation and data loading
            CategoriesView()
            
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
        .onChange(of: isAppReady) { oldValue, newValue in
            if newValue && animationComplete {
                DispatchQueue.main.async {
                    withAnimation { showLaunchAnimation = false }
                }
            }
        }
    }
}

// MARK: Preview

#Preview("Pro-$0") {
    WithManagers(userTier: .pro, incurredCost: 0) {
        ContentView(isAppReady: .constant(true))
    }
}

#Preview("None-$0") {
    WithManagers(userTier: .none, incurredCost: 0) {
        ContentView(isAppReady: .constant(true))
    }
}
