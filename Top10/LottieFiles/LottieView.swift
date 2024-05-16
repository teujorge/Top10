//
//  LottieView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/16/24.
//

import Lottie
import SwiftUI

// LottieView struct to display Lottie animations
struct LottieView: UIViewRepresentable {
    let name: String
    let loopMode: LottieLoopMode
    let contentMode: UIView.ContentMode
    let animationSpeed: CGFloat
    let onAnimationEnd: (() -> Void)?
    let fromFrame: CGFloat?
    let toFrame: CGFloat?
    
    @Binding var play: Bool
    private var animationView: LottieAnimationView
    
    init(
        name: String,
        loopMode: LottieLoopMode = .loop,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        animationSpeed: CGFloat = 1,
        onAnimationEnd: (() -> Void)? = nil,
        fromFrame: CGFloat? = nil,
        toFrame: CGFloat? = nil,
        play: Binding<Bool> = .constant(true)
    ) {
        self.name = name
        self.loopMode = loopMode
        self.contentMode = contentMode
        self.animationSpeed = animationSpeed
        self.onAnimationEnd = onAnimationEnd
        self.fromFrame = fromFrame
        self.toFrame = toFrame
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
        guard play else { return }
        
        animationView.play(
            fromFrame: (fromFrame ?? animationView.animation?.startFrame) ?? 0,
            toFrame: (toFrame ?? animationView.animation?.endFrame) ?? 0,
            completion: { _ in
                play = false
                onAnimationEnd?()
            }
        )
    }
}
