//
//  SignInView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI
import AuthenticationServices

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
                            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isSignedIn)
                            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.contWithoutSignIn)
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
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.contWithoutSignIn)
            }) {
                Text("Continue without signing in")
                    .padding()
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    SignInView(isSignedIn: .constant(false), continueWithoutSignIn: .constant(false))
}
