//
//  GameView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import UIKit
import SwiftUI
import AVFAudio

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var entitlementManager: EntitlementManager
    
    var category: String // The selected category
    var top10: [String] // The top 10 items for the selected category
    var players: [String] // The list of players
    
    @State private var guess = "" // State variable to hold the current guess
    @State private var guesses = [String]() // State variable to hold the list of guesses
    @State private var inputError: String? = nil // State to handle input errors
    @State private var hasWon = false // State to handle winning state
    @State private var isLoading = false // State to handle loading state
    @State private var showCelebration = false // State to handle the celebration animation

    @State private var audioPlayerManager = AudioPlayerManager() // StateObject to manage audio playback
    
    @FocusState private var isTextFieldFocused: Bool
    
    private func sendUserGuess() {
        Task {
            guard !guess.isEmpty else { return }
            
            if guesses.map({ $0.lowercased() }).contains(guess.lowercased()) {
                vibrate()
                inputError = "You already guessed that!"
            } else {
                isLoading = true
                
                if let guessResponse = await handleUserGuess(answers: top10, guess: guess, entitlementManager: entitlementManager) {
                    
                    // Use TTS to generate speech for the response.speech
                    Task {
                        if let speech = guessResponse.speech {
                            if let audioData = await generateSpeech(input: speech, entitlementManager: entitlementManager) {
                                audioPlayerManager.playAudio(audioData)
                            }
                        }
                    }
                    
                    // Check if the response contains a suggestion
                    if let suggestion = guessResponse.suggestion {
                        inputError = "Did you mean: \(suggestion)?"
                    }
                    // Check if the response contains a match
                    else {
                        let match = guessResponse.match
                        // Check if the guess is incorrect
                        if match == nil {
                            print("Incorrect guess!")
                            withAnimation { guesses.insert(guess, at: 0) }
                        }
                        // Check if the guess is correct
                        else {
                            print("Correct guess!")
                            withAnimation { 
                                guesses.insert(match!, at: 0)
                            }
                            
                            // Win scenario
                            if (guesses.filter { top10.contains($0) }).count == top10.count {
                                
                                vibrate()
                                withAnimation {
                                    hasWon = true
                                }
                                showCelebration = true
                            }
                            
                            
                        }
                    }
                    
                }
                // guessResponse is nil
                else {
                    vibrate()
                    inputError = "An error occurred. Please try again."
                }
                
                isLoading = false
                guess = ""
            }
        }
    }
    
    var body: some View {
        // VStack arranges its children in a vertical stack
        VStack(spacing: 0) {
            // List with a gradient overlay to display the submitted guesses
            ZStack {
                // List of guesses
                List {
                    Section(header: Text("Correct")) {
                        ForEach(guesses.filter { top10.contains($0) }, id: \.self) { guess in
                            Text(guess)
                                .foregroundColor(.green)
                                .transition(.move(edge: .top))
                                .animation(.default, value: guesses)
                        }
                    }
                    Section(header: Text("Incorrect")) {
                        ForEach(guesses.filter { !top10.contains($0) }, id: \.self) { guess in
                            Text(guess)
                                .foregroundColor(.red)
                                .transition(.move(edge: .top))
                                .animation(.default, value: guesses)
                        }
                    }
                }
                
                // Full Screen Celebration Animation (Lottie)
                if showCelebration {
                    LottieView(
                        name: guesses.count > 30 ? "GiraffeCelebration" : "StarsCelebration",
                        loopMode: .playOnce,
                        contentMode: .scaleAspectFill,
                        onAnimationEnd: { showCelebration = false },
                        toFrame: guesses.count > 30 ? 200 : 90
                    )
                }
            }
            .animation(.easeInOut, value: inputError)
            
            Divider()
            
            // Error message for duplicate guesses
            if !hasWon {
                Text(inputError ?? "")
                    .foregroundColor(.red)
                    .opacity(inputError == nil ? 0 : 1)
                    .transition(.opacity)
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut, value: inputError)
                
                // User input area
                HStack {
                    // TextField for the user to enter their guess
                    TextField("Enter your guess", text: $guess)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isTextFieldFocused)
                        .onChange(of: guess) { inputError = nil }
                        .opacity(isLoading ? 0.5 : 1.0)
                    
                    // Button to submit the guess
                    if isLoading {
                        ProgressView()
                            .padding(.horizontal, 31)
                    }
                    else {
                        Button(action: sendUserGuess) {
                            Text("Guess")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundColor(.white)
                        }
                        .cornerRadius(6)
                        .disabled(isLoading)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
            }
            else {
                Button(action: { dismiss() }) {
                    Text("Back home")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .navigationTitle("Top 10 \(category)")
        .onAppear() {
            isTextFieldFocused = true
        }
    }
}

// MARK: AudioPlayerManager

class AudioPlayerManager: NSObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?

    override init() {
        super.init()
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    func playAudio(_ data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error)")
        }
    }

    // AVAudioPlayerDelegate methods
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // Handle audio player finish
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        // Handle audio player error
        if let error = error {
            print("Audio player error: \(error)")
        }
    }
}


// MARK: Preview

#Preview {
    WithManagers {
        GameView(category: "Fruits", top10: ["Apple", "Banana", "Cherry"], players: ["Guimell", "Teu", "Lipe", "FG", "Cadios"])
    }
}
