//
//  CategoriesView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI

// MARK: - CategoryView

struct CategoryView: View {
    
    @Binding var isSignedIn: Bool
    @Binding var continueWithoutSignIn: Bool
    
    @State private var selectedCategory = ""
    @State private var selectedTop10: [String]?
    
    @State private var isDefaultCategoriesExpanded = true
    @State private var isGeneratedCategoriesExpanded = true
    
    @State private var isShowingCategoryOptionsSheet = false
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
        // NavigationStack allows for navigation between views
        NavigationStack {
            VStack {
                // List of categories
                List {
                    defaultCategoriesSection()
                    generatedCategoriesSection()
                }
                .listStyle(InsetGroupedListStyle())
                
                // Bottom Action Buttons
                HStack {
                    Spacer()
                    
                    // Button to sign out
                    Button(action: {
                        isSignedIn = false
                        continueWithoutSignIn = false
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isSignedIn)
                        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.contWithoutSignIn)
                    }) {
                        Text(isSignedIn ? "Sign out" : "Sign in")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    // Button to generate new top 10 list
                    NavigationLink(destination: GenerateCategoryView()) {
                        Text("Generator")
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Categories")
            .onAppear() { loadGeneratedLists() }
            .sheet(isPresented: $isShowingCategoryOptionsSheet) {
                CategoryOptionsSheetView(
                    category: $selectedCategory,
                    top10: $selectedTop10,
                    showCategoryOptionsSheet: $isShowingCategoryOptionsSheet
                )
            }
            .presentationDetents([.medium, .large])
        }
    }
    
    private func defaultCategoriesSection() -> some View {
        Section {
            DisclosureGroup(
                isExpanded: $isDefaultCategoriesExpanded,
                content: {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: GameView(
                            category: category,
                            top10: category == "Cars" ? top10Cars : category == "Movies" ? top10Movies : top10Books
                        )) {
                            Text(category)
                        }
                    }
                },
                label: {
                    Text("Default Categories (\(categories.count))")
                        .bold()
                }
            )
        }
    }
    
    private func generatedCategoriesSection() -> some View {
        Section {
            DisclosureGroup(
                isExpanded: $isGeneratedCategoriesExpanded,
                content: {
                    ForEach(generatedCategories.keys.sorted(), id: \.self) { category in
                        NavigationLink(destination: GameView(
                            category: category,
                            top10: generatedCategories[category] ?? []
                        )) {
                            Text(category)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(action: {
                                
                                selectedCategory = category
                                selectedTop10 = generatedCategories[category]
                                
                                print("Options for \(selectedCategory)")
                                print("Top 10: \(selectedCategory)")
                                
                                isShowingCategoryOptionsSheet.toggle()
                            }) {
                                Label("Options", systemImage: "ellipsis")
                            }
                            
                            Button(role: .destructive, action: {
                                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.generatedListPrefix + category)
                                generatedCategories.removeValue(forKey: category)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                },
                label: {
                    Text("Generated Categories (\(generatedCategories.count))")
                        .bold()
                }
            )
        }
        .opacity(isSignedIn ? 1 : 0.5)
        .disabled(!isSignedIn)
    }
}

// MARK: - CategoryOptionsSheetView

struct CategoryOptionsSheetView: View {
    
    @Binding var category: String
    @Binding var top10: [String]?
    @Binding var showCategoryOptionsSheet: Bool
    
    @State private var newCategoryName = ""
    @State private var selectedItem = ""
    
    @State private var hideItemText = true
    @State private var showItemOptionsSheet = false
    
    private func saveRename() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.generatedListPrefix + category)
        UserDefaults.standard.set(top10, forKey: UserDefaultsKeys.generatedListPrefix + newCategoryName)
        
        category = newCategoryName
        showCategoryOptionsSheet.toggle()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { showCategoryOptionsSheet.toggle() }) {
                    Text("Cancel")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: saveRename) {
                    Text("Save")
                        .foregroundColor(.blue)
                        .bold()
                }
            }
            .padding()
            
            TextField("Rename item", text: $newCategoryName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            List {
                Section {
                    Toggle(isOn: $hideItemText) {
                        Text("Blur text")
                    }
                }
                
                ForEach(top10 ?? [], id: \.self) { item in
                    Text(item)
                        .blur(radius: hideItemText ? 5 : 0)
                        .swipeActions(edge: .leading) {
                            Button(action: {
                                selectedItem = item
                                showItemOptionsSheet.toggle()
                            }) {
                                Label("Options", systemImage: "ellipsis")
                            }
                            
                            Button(role: .destructive, action: {
                                withAnimation { top10?.removeAll(where: { $0 == item }) }
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .animation(.default, value: top10)
                        .animation(.default, value: hideItemText)
                }
            }
        }
        .onAppear {
            newCategoryName = category
        }
        .sheet(isPresented: $showItemOptionsSheet) {
            TopTenItemOptionsBottomSheetView(item: $selectedItem, top10: $top10, showBottomSheet: $showItemOptionsSheet)
                .presentationDetents([.height(150)])
        }
    }
}

// MARK: - Preview

#Preview {
    CategoryView(isSignedIn: .constant(true), continueWithoutSignIn: .constant(false)).previewDisplayName("Signed In")
}

#Preview {
    CategoryView(isSignedIn: .constant(false), continueWithoutSignIn: .constant(true)).previewDisplayName("Not Signed In")
}

