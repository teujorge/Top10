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
    @State private var playAnimation = false
    @State private var showLaunchAnimation = true
    
    // Async timer to hide the launch animation
    func handleLaunchAnimation() {
        Task {
            do {
                // Start launch animation
                try await Task.sleep(nanoseconds: 500_000_000)
                playAnimation = true
                
                // Hide launch animation
                try await Task.sleep(nanoseconds: 1_000_000_000)
                withAnimation { showLaunchAnimation = false }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    var body: some View {
        ZStack {
            // Main content displayed after animation and data loading
            CategoriesView()
            
            // App Logo Animation
            if showLaunchAnimation || !isAppReady {
                GeometryReader { geometry in
                    ZStack {
                        Color(.black)
                            .ignoresSafeArea()
                        
                        LottieView(
                            name: LottieAnimations.logoAnimation,
                            loopMode: .playOnce,
                            animationSpeed: 2,
                            play: $playAnimation
                        )
                        .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                    }
                }
                .transition(.opacity)
                .animation(.easeInOut, value: isAppReady)
                .animation(.easeInOut, value: showLaunchAnimation)
            }
        }
        .onAppear {
            handleLaunchAnimation()
        }
    }
}



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
