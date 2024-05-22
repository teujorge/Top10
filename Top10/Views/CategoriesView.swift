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
    
    // MARK: Properties
    
    @EnvironmentObject var userData: UserData
    
    @State private var searchText = ""
    
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
    
    private var filteredDefaultCategories: [String] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private var filteredGeneratedCategories: [String: [String]] {
        if searchText.isEmpty {
            return generatedCategories
        } else {
            return generatedCategories.filter { $0.key.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    // MARK: Body
    
    var body: some View {
        // NavigationStack allows for navigation between views
        NavigationStack {
            ZStack(alignment: .bottom) {
                // List of categories
                List {
                    defaultCategoriesSection
                    generatedCategoriesSection
                }
                .listStyle(InsetGroupedListStyle())
                .animation(.easeInOut, value: searchText)
                
                // Search Bar
                TextField("Search", text: $searchText)
                    .textFieldStyle(CustomTextFieldStyle())
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
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
                    Group {
                        ForEach(filteredDefaultCategories, id: \.self) { category in
                            NavigationLink(destination: SetupView(
                                category: category,
                                top10: category == "Cars" ? top10Cars : category == "Movies" ? top10Movies : top10Books
                            )) {
                                Text(category)
                            }
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
                    ForEach(filteredGeneratedCategories.keys.sorted(), id: \.self) { category in
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
        .disabled(userData.tier == .none)
        .opacity(userData.tier == .none ? 0.5 : 1.0)
        
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
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Rename Category")
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)
                
                TextField("Rename item", text: $newCategoryName)
                    .textFieldStyle(CustomTextFieldStyle())
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            
            Divider()
            
            List {
                Section {
                    Toggle(isOn: $hideItemText) {
                        Text("Blur text")
                    }
                }
                
                Section(header: Text("Edit List")) {
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

// MARK: PreferenceKey
// to track the view's offset
struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: Preview

#Preview {
    CategoriesView()
        .environmentObject(UserData())
}
