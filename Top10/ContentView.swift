//
//  ContentView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/14/24.
//

import SwiftUI
import AuthenticationServices

let IS_SIGNED_IN = "isSignedIn"
let CONTINUE_WITHOUT_SIGN_IN = "continueWithoutSignIn"

// MARK: Main Content View
struct ContentView: View {
    @State private var isSignedIn: Bool = UserDefaults.standard.bool(forKey: IS_SIGNED_IN) {
        didSet {
            UserDefaults.standard.set(isSignedIn, forKey: IS_SIGNED_IN)
        }
    }
    @State private var continueWithoutSignIn: Bool = UserDefaults.standard.bool(forKey: CONTINUE_WITHOUT_SIGN_IN) {
        didSet {
            UserDefaults.standard.set(continueWithoutSignIn, forKey: CONTINUE_WITHOUT_SIGN_IN)
        }
    }

    var body: some View {
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
    }
}

// MARK: Sign In View
struct SignInView: View {
    @Binding var isSignedIn: Bool
    @Binding var continueWithoutSignIn: Bool
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            Spacer()
            
            Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: 200)
                .padding()
                .padding(.bottom, 50)
            
            Spacer()
            
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
                            continueWithoutSignIn = false
                            UserDefaults.standard.set(true, forKey: IS_SIGNED_IN)
                            UserDefaults.standard.set(false, forKey: CONTINUE_WITHOUT_SIGN_IN)
                        }
                    case .failure(let error):
                        // Handle error.
                        print(error.localizedDescription)
                    }
                }
            )
            .signInWithAppleButtonStyle(.whiteOutline)
            .frame(width: 280, height: 45)
            
            Button(action: {
                continueWithoutSignIn = true
                UserDefaults.standard.set(true, forKey: CONTINUE_WITHOUT_SIGN_IN)
            }) {
                Text("Continue without signing in")
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: Category View
struct CategoryView: View {
    @Binding var isSignedIn: Bool
    @Binding var continueWithoutSignIn: Bool
    
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
        
        Spacer()
        
        Button(action: {
            isSignedIn = false
            continueWithoutSignIn = false
            UserDefaults.standard.set(false, forKey: IS_SIGNED_IN)
            UserDefaults.standard.set(false, forKey: CONTINUE_WITHOUT_SIGN_IN)
        }) {
            Text(isSignedIn ? "Sign out" : "Sign in")
                .padding()
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

// MARK: Guessing Game View
struct GuessingGameView: View {
    var category: String // The selected category
    var top10: [String] // The top 10 items for the selected category
    @State private var guess = "" // State variable to hold the current guess
    @State private var guesses = [String]() // State variable to hold the list of guesses
    @State private var inputError: String? = nil // State to handle duplicate guess error
    
    var body: some View {
        /// VStack arranges its children in a vertical stack
        VStack {
            /// Display the title of the guessing game
            Text("Guess the Top 10 \(category)!")
                .font(.title)
                .padding()
            
            /// TextField for the user to enter their guess
            TextField("Enter your guess", text: $guess)
                  .textFieldStyle(RoundedBorderTextFieldStyle())
                  .padding(.horizontal)
                  .onChange(of: guess) { inputError = nil }
            
            /// Error message for duplicate guesses
            Text("You already guessed that!")
                    .foregroundColor(.red)
                    .opacity(inputError == nil ? 0 : 1)
                    .transition(.opacity)
                    .animation(. easeInOut, value: inputError)

            /// Button to submit the guess
            Button(action: {
                if guess.isEmpty { return }
                if guesses.contains(guess) {
                    vibrate() // Vibrate the device
                    inputError = "You already guessed that!"
                } else {
                    withAnimation { guesses.insert(guess, at: 0) }
                    guess = ""
                }
            }) {
                Text("Submit Guess")
                    .font(.headline)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .cornerRadius(10)
            
            /// Title for the list of guesses
            Text("Guesses")
                .font(.headline)
                .padding(.top)
            
            /// List with a gradient overlay to display the submitted guesses
            ZStack {
                List(guesses, id: \.self) { guess in
                    Text(guess) // Display each guess
                        .foregroundColor(top10.contains(guess) ? .green : .red )
                        .transition(.move(edge: .top))
                        .animation(.default, value: guesses)
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
    
    // Function to vibrate the device
    private func vibrate() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

// MARK: Previews
/// New Xcode SwiftUI previews (available in recent versions of Xcode)

#Preview("ContentView") {
    ContentView()
}

#Preview("GuessingGameView-Fruits") {
    GuessingGameView(category: "Fruits", top10: ["Apple", "Banana", "Cherry"])
        .previewDisplayName("Fruits Category")
}

#Preview("GuessingGameView-Animals") {
    GuessingGameView(category: "Animals", top10: ["Lion", "Tiger", "Bear"])
        .previewDisplayName("Animals Category")
}
