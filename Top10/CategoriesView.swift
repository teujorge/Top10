//
//  CategoriesView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI

// MARK: Category View
struct CategoryView: View {
    
    @Binding var isSignedIn: Bool
    @Binding var continueWithoutSignIn: Bool
    
    @State private var showBottomSheet = false
    @State private var generatedCategories: [String: [String]] = [:]
    
    // Hardcoded list of categories and top10 answers for the user to choose from
    let categories = ["Cars", "Movies", "Books"]
    let top10Cars = ["Toyota", "Ford", "Chevrolet", "Honda", "Nissan", "Jeep", "BMW"]
    let top10Movies = ["The Shawshank Redemption", "The Godfather", "The Dark Knight", "The Lord of the Rings", "Pulp Fiction", "Inception"]
    let top10Books = ["To Kill a Mockingbird", "1984", "The Lord of the Rings", "Harry Potter", "Animal Farm", "The Great Gatsby", "The Hobbit", "Fahrenheit 451"]

    private func loadGeneratedLists() {
        let allKeys = UserDefaults.standard.dictionaryRepresentation().keys
        let filteredKeys = allKeys.filter { $0.hasPrefix(UserDefaultsKeys.generatedListPrefix) }
        
        for key in filteredKeys {
            if let list = UserDefaults.standard.array(forKey: key) as? [String] {
                let category = key.replacingOccurrences(of: UserDefaultsKeys.generatedListPrefix, with: "")
                generatedCategories[category] = list
            }
        }
    }

    var body: some View {
        // NavigationView allows for navigation between views
        NavigationView {
            VStack {
                categoriesList()
                
                Spacer()
                
                /// Button to sign out
                Button(action: {
                    isSignedIn = false
                    continueWithoutSignIn = false
                    UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isSignedIn)
                    UserDefaults.standard.set(false, forKey: UserDefaultsKeys.contWithoutSignIn)
                }) {
                    Text(isSignedIn ? "Sign out" : "Sign in")
                        .padding()
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .navigationTitle("Categories") // Title for the navigation bar
            .onAppear() { loadGeneratedLists() }
        }
    }
    
    private func defaultCategoriesSection() -> some View {
        Section(header: Text("Default Categories")) {
            ForEach(categories, id: \.self) { category in
                NavigationLink(destination: GameView(
                    category: category,
                    top10: category == "Cars" ? top10Cars : category == "Movies" ? top10Movies : top10Books
                )) {
                    Text(category)
                }
            }
        }
    }
    
    private func generatedCategoriesSection() -> some View {
        Section(header: Text("Generated Categories")) {
            // Button to navigate to GenerateCategoryView
            NavigationLink(destination: GenerateCategoryView()) {
                Text("Generate Category")
                    .foregroundColor(.blue)
                    .bold()
            }
            
            // Buttons for each generated category
            ForEach(generatedCategories.keys.sorted(), id: \.self) { category in
                NavigationLink(destination: GameView(
                    category: category,
                    top10: generatedCategories[category] ?? []
                )) {
                    Text(category)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    Button(role: .destructive, action: {
                        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.generatedListPrefix + category)
                        generatedCategories.removeValue(forKey: category)
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .opacity(isSignedIn ? 1 : 0.5)
        .disabled(!isSignedIn)
    }
    
    private func categoriesList() -> some View {
        List {
            defaultCategoriesSection()
            generatedCategoriesSection()
        }
        .listStyle(InsetGroupedListStyle())
    }
}

#Preview {
    CategoryView(isSignedIn: .constant(true), continueWithoutSignIn: .constant(false)).previewDisplayName("Signed In")
}

#Preview {
    CategoryView(isSignedIn: .constant(false), continueWithoutSignIn: .constant(true)).previewDisplayName("Not Signed In")
}
