//
//  GameView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI
import AVFAudio
import OpenAI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var entitlementManager: EntitlementManager
    
    var category: String // The selected category
    var top10: [String] // The top 10 items for the selected category
    var players: [String] // The list of players
    
    @State private var guess = "" // Hold the current guess
    @State private var guesses = [String]() // Hold the list of guesses
    @State private var inputError: String? = nil // Handle input errors
    @State private var hasWon = false // Handle winning state
    @State private var isLoading = false // Handle loading state
    @State private var showCelebration = false // Handle the celebration animation
    @State private var conversation: [ChatQuery.ChatCompletionMessageParam] = [] // Store the conversation
    @State private var audioPlayerManager = AudioPlayerManager() // StateObject to manage audio playback
    
    @FocusState private var isTextFieldFocused: Bool
    
    private func sendUserGuess() {
        Task {
            guard !guess.isEmpty else { return }
            
            if guesses.map({ $0.lowercased() }).contains(guess.lowercased()) {
                vibrate()
                inputError = "You already guessed that!"
                return
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    isLoading = true
                }
            }
            
            if let guessResponse = await handleUserGuess(answers: top10, guess: guess, conversationHistory: conversation, entitlementManager: entitlementManager) {
                
                if let conversationUpdate = guessResponse.conversation {
                    conversation = conversationUpdate
                }
                
                if let speech = guessResponse.speech {
                    Task {
                        if let audioData = await generateSpeech(input: speech, entitlementManager: entitlementManager) {
                            audioPlayerManager.playAudio(audioData)
                        }
                    }
                }
                
                if guessResponse.isHint {
                    inputError = "Hint: \(guessResponse.speech ?? "nil")"
                } else if guessResponse.hasGuessed {
                    inputError = guessResponse.speech
                } else if let match = guessResponse.match {
                    print("Correct guess!")
                    withAnimation { guesses.insert(match, at: 0) }
                    
                    if guesses.filter({ top10.contains($0) }).count == top10.count {
                        vibrate()
                        withAnimation { hasWon = true }
                        showCelebration = true
                    }
                } else {
                    print("Incorrect guess!")
                    withAnimation { guesses.insert(guess, at: 0) }
                }
            } else {
                vibrate()
                inputError = "An error occurred. Please try again."
            }
            
            DispatchQueue.main.async {
                withAnimation {
                    self.isLoading = false
                    self.guess = ""
                }
            }
        }
    }

    
    
    var body: some View {
        ZStack(alignment: .bottom) {
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
            
            // Game over view
            if !hasWon {
                VStack {
                    // Error messaging
                    Text(inputError ?? "")
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .foregroundColor(.red)
                        .clipShape(.capsule)
                        .opacity(inputError == nil ? 0 : 1)
                        .transition(.opacity)
                        .animation(.easeInOut, value: inputError)
                        .padding()
                    
                    Spacer()
                    
                    // User input area
                    HStack {
                        // TextField for the user to enter their guess
                        TextField("Enter your guess", text: $guess)
                            .textFieldStyle(CustomTextFieldStyle())
                            .focused($isTextFieldFocused)
                            .onChange(of: guess) { inputError = nil }
                        
                        // Button to submit the guess
                        if isLoading {
                            ProgressView()
                                .frame(width: 40, height: 40)
                        }
                        else {
                            Button(action: sendUserGuess) {
                                Image(systemName: "paperplane")
                                    .padding(12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .clipShape(.circle)
                            }
                            .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
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
