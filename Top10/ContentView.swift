//
//  ContentView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/14/24.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    @State private var playAnimation = false
    @State private var showLaunchAnimation = true
    
    // Async timer to hide the launch animation
    func handleLaunchAnimation() {
        Task {
            do {
                // Start launch animation
                try await Task.sleep(nanoseconds: 1_000_000_000)
                withAnimation {
                    playAnimation = true
                }
                
                // Hide animation after 3 seconds
                try await Task.sleep(nanoseconds: 3_000_000_000)
                withAnimation {
                    showLaunchAnimation = false
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    var body: some View {
        ZStack{
            CategoriesView()
            
            // App Logo Animation
            GeometryReader { geometry in
                ZStack {
                    Color(.black)
                        .ignoresSafeArea()
                    
                    LottieView(name: LottieAnimations.logoAnimation, loopMode: .playOnce, animationSpeed: 2, play: $playAnimation)
                        .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                }
            }
            .opacity(showLaunchAnimation ? 1 : 0)
            .animation(.easeInOut(duration: 0.5), value: showLaunchAnimation)
        }
        .onAppear() {
            handleLaunchAnimation()
        }
    }
}

#Preview("ContentView") {
    ContentView()
}
