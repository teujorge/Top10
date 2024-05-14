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
    @State private var isSignedIn = false
    
    var body: some View {
        #if DEBUG
        CategoryView()
        #else
        if isSignedIn {
            CategoryView()
        } else {
            SignInView(isSignedIn: $isSignedIn)
        }
        #endif
    }
}

// MARK: Sign In View
struct SignInView: View {
    @Binding var isSignedIn: Bool

    var body: some View {
        VStack {
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    switch result {
                    case .success(let authorization):
                        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                            let userIdentifier = appleIDCredential.user
                            let fullName = appleIDCredential.fullName
                            let email = appleIDCredential.email
                            
                            // Save the userIdentifier in your app's storage for future authentication checks.
                            print("User ID: \(userIdentifier)")
                            print("Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
                            print("Email: \(email ?? "")")
                            
                            isSignedIn = true
                        }
                    case .failure(let error):
                        // Handle error.
                        print(error.localizedDescription)
                    }
                }
            )
            .signInWithAppleButtonStyle(.black)
            .frame(width: 280, height: 45)
            .padding()
        }
    }
}

// MARK: Category View
struct CategoryView: View {
    /// Hardcoded list of categories and top10 answers for the user to choose from
    let categories = ["Cars", "Movies", "Books"]
    let top10Cars = ["Toyota", "Ford", "Chevrolet", "Honda", "Nissan", "Jeep", "Subaru", "Hyundai", "Kia", "BMW"]
    let top10Movies = ["The Shawshank Redemption", "The Godfather", "The Dark Knight", "The Lord of the Rings: The Return of the King", "Pulp Fiction", "Schindler's List", "The Lord of the Rings: The Fellowship of the Ring", "Forrest Gump", "Star Wars: Episode V - The Empire Strikes Back", "Inception"]
    let top10Books = ["To Kill a Mockingbird", "1984", "The Lord of the Rings", "The Catcher in the Rye", "Harry Potter and the Philosopher's Stone", "Animal Farm", "The Great Gatsby", "The Hobbit", "Fahrenheit 451", "Pride and Prejudice"]

    var body: some View {
        /// NavigationView allows for navigation between views
        NavigationView {
            /// List displays the categories in a scrollable list
            List(categories, id: \.self) { category in
                /// NavigationLink creates a link to the GuessingGameView when a category is tapped
                NavigationLink(destination: GuessingGameView(
                        category: category, top10: category == "Cars" ? top10Cars : category == "Movies" ? top10Movies : top10Books
                )) {
                    Text(category) // Displays the category name
                }
            }
            .navigationTitle("Categories") // Title for the navigation bar
        }
    }
}

// MARK: Guessing Game View
struct GuessingGameView: View {
    var category: String // The selected category
    var top10: [String] // The top 10 items for the selected category
    @State private var guess = "" // State variable to hold the current guess
    @State private var guesses = [String]() // State variable to hold the list of guesses
    
    var body: some View {
        /// VStack arranges its children in a vertical stack
        VStack {
            /// Display the title of the guessing game
            Text("Guess the Top 10 \(category)!")
                .font(.title) // Set the font size to title
                .padding() // Add padding around the text
            
            /// TextField for the user to enter their guess
            TextField("Enter your guess", text: $guess)
                .textFieldStyle(RoundedBorderTextFieldStyle()) // Use rounded border style for the text field
                .padding() // Add padding around the text field
            
            /// Button to submit the guess
            Button(action: {
                /// Add the guess to the list if it's not empty
                if !guess.isEmpty {
                    guesses.append(guess)
                    guess = "" // Clear the text field
                }
            }) {
                Text("Submit Guess")
                    .font(.headline) // Set the font size to headline
                    .padding() // Add padding inside the button
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            /// Title for the list of guesses
            Text("Guesses")
                .font(.headline)
                .padding(.top)
            
            /// List with a gradient overlay to display the submitted guesses
            ZStack {
                List(guesses, id: \.self) { guess in
                    Text(guess) // Display each guess
                        .foregroundColor(top10.contains(guess) ? .green : .red )
                }

                /// Top gradient overlay
                VStack {
                    LinearGradient(gradient: Gradient(colors: [Color(UIColor.systemBackground).opacity(0.8), Color(UIColor.systemBackground).opacity(0)]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 20)
                    Spacer()
                }
            }
        }
        .navigationTitle(category) // Title for the navigation bar
    }
}

/// New Xcode SwiftUI previews (available in recent versions of Xcode)
#Preview {
    ContentView()
}
