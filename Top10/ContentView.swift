//
//  ContentView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/14/24.
//

import SwiftUI
import AuthenticationServices

// MARK: Main Content View
struct ContentView: View {
    @State private var playAnimation = false
    @State private var showLaunchAnimation = true
    @State private var isSignedIn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isSignedIn) {
        didSet {
            UserDefaults.standard.set(isSignedIn, forKey: UserDefaultsKeys.isSignedIn)
        }
    }
    @State private var continueWithoutSignIn: Bool = UserDefaults.standard.bool(forKey: UserDefaultsKeys.contWithoutSignIn) {
        didSet {
            UserDefaults.standard.set(continueWithoutSignIn, forKey: UserDefaultsKeys.contWithoutSignIn)
        }
    }
    
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
            /// App Content
            VStack {
                if isSignedIn || continueWithoutSignIn {
                    CategoryView(isSignedIn: $isSignedIn, continueWithoutSignIn: $continueWithoutSignIn)
                        .transition(.move(edge: .trailing))
                } else {
                    SignInView(isSignedIn: $isSignedIn, continueWithoutSignIn: $continueWithoutSignIn)
                        .transition(.move(edge: .leading))
                }
            }
            .animation(.easeInOut, value: isSignedIn) // Animate the value change
            .animation(.easeInOut, value: continueWithoutSignIn) // Animate the value change
            
            /// App Logo Animation
            GeometryReader { geometry in
                ZStack {
                    Color(.systemBackground)
                        .ignoresSafeArea()
                    
                    LottieView(name: LottieAnimations.logoAnimation, loopMode: .playOnce, animationSpeed: 5, play: $playAnimation)
                        .frame(width: min(geometry.size.width, geometry.size.height), height: min(geometry.size.width, geometry.size.height))
                        .offset(y: -50)
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

// MARK: Previews
/// New Xcode SwiftUI previews (available in recent versions of Xcode)

#Preview("ContentView") {
    ContentView()
}
