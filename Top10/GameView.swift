//
//  GameView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import UIKit
import SwiftUI

// MARK: Game View
struct GameView: View {
    var category: String // The selected category
    var top10: [String] // The top 10 items for the selected category
    
    @State private var guess = "" // State variable to hold the current guess
    @State private var guesses = [String]() // State variable to hold the list of guesses
    @State private var inputError: String? = nil // State to handle duplicate guess error
    @State private var isLoading = false // State to handle loading state
    
    var body: some View {
        // VStack arranges its children in a vertical stack
        VStack {
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

                // Bottom gradient overlay
                VStack {
                    Spacer()
                    LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground).opacity(1), Color(UIColor.systemBackground).opacity(0)]), startPoint: .bottom, endPoint: .top)
                        .frame(height: 20)
                }
            }
            .animation(.easeInOut, value: inputError)

            // Error message for duplicate guesses
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
                    .onChange(of: guess) { inputError = nil }
                    //.disabled(isLoading)
                    //.keyboardType(.alphabet)
                    //.autocapitalization(.none)
                    //.disableAutocorrection(true)

                // Button to submit the guess
                if isLoading {
                    ProgressView()
                        .padding(.horizontal, 31)
                }
                else {
                    Button(action: {

                        Task {
                            guard !guess.isEmpty else { return }
                            
                            if guesses.map({ $0.lowercased() }).contains(guess.lowercased()) {
                                vibrate()
                                inputError = "You already guessed that!"
                            } else {
                                isLoading = true
                                
                                if let guessResponse = await handleUserGuess(answers: top10, guess: guess) {
                                    
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
                                            withAnimation { guesses.insert(match!, at: 0) }
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
                    }) {
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
        .navigationTitle("Top 10 \(category)") // Title for the navigation bar
    }
}

#Preview("GuessingGameView-Fruits") {
    GameView(category: "Fruits", top10: ["Apple", "Banana", "Cherry"])
}
