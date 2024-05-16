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

// LottieView struct to display Lottie animations
struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let contentMode: UIView.ContentMode
    let animationSpeed: CGFloat

    @Binding var play: Bool
    private var animationView: LottieAnimationView
    
    init(
        name: String,
        loopMode: LottieLoopMode = .loop,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        animationSpeed: CGFloat = 1,
        play: Binding<Bool> = .constant(true)
    ) {
        self.name = name
        self.loopMode = loopMode
        self.contentMode = contentMode
        self.animationSpeed = animationSpeed
        self._play = play
        self.animationView = LottieAnimationView(name: name)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.addSubview(animationView)
        
        animationView.loopMode = loopMode
        animationView.contentMode = contentMode
        animationView.animationSpeed = animationSpeed
        animationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if play {
            animationView.play { _ in
                play = false
            }
        }
    }
}


// Function to vibrate the device
func vibrate() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
}
