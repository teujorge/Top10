//
//  CategoriesView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI
import StoreKit

// MARK: - CategoryView

struct CategoriesView: View {
    
    @EnvironmentObject private var entitlementManager: EntitlementManager
    
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
    
    private func showManageSubscriptions() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        Task {
            do {
                try await AppStore.showManageSubscriptions(in: windowScene)
            }
            catch {
                print("Error showing manage subscriptions: \(error)")
            }
        }
    }
    
    var body: some View {
        // NavigationStack allows for navigation between views
        NavigationStack {
            VStack(spacing: 0) {
                // List of categories
                List {
                    defaultCategoriesSection
                    generatedCategoriesSection
                }
                .listStyle(InsetGroupedListStyle())
                
                Divider()
                
                // Bottom Action Buttons
                HStack {
                    Spacer()
                    
                    // Button to manage subscriptions
                    if entitlementManager.userTier == .none {
                        // View to purchase subscriptions
                        NavigationLink(destination: SubscriptionsView()) {
                            Text("Subscriptions")
                                .foregroundColor(.blue)
                        }
                    }
                    else {
                        // View to manage subscriptions
                        Button (action: showManageSubscriptions) {
                            Text("Subscription")
                                .foregroundColor(.blue)
                        }
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
    
    // MARK: Views
    
    private var defaultCategoriesSection: some View {
        Section {
            DisclosureGroup(
                isExpanded: $isDefaultCategoriesExpanded,
                content: {
                    ForEach(categories, id: \.self) { category in
                        NavigationLink(destination: SetupView(
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
    
    private var generatedCategoriesSection: some View {
        Section {
            DisclosureGroup(
                isExpanded: $isGeneratedCategoriesExpanded,
                content: {
                    ForEach(generatedCategories.keys.sorted(), id: \.self) { category in
                        NavigationLink(destination: SetupView(
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
        .opacity(entitlementManager.userTier == .none ? 0.5 : 1.0)
        .disabled(entitlementManager.userTier == .none)
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
        VStack(spacing: 0) {
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
                .padding()
            
            Divider()
            
            List {
                Section {
                    Toggle(isOn: $hideItemText) {
                        Text("Blur text")
                    }
                }
                
                ForEach(top10 ?? [], id: \.self) { item in
                    Text(item)
                        .blur(radius: hideItemText ? 5 : 0)
                        .swipeActions(edge: .trailing) {
                            if hideItemText == false {
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
    CategoriesView()
}

