//
//  GeneratedCategoryView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI


// MARK: - GeneratedCategoryView

struct GeneratedCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var entitlementManager: EntitlementManager
    
    @Binding var top10: [String]?
    @Binding var category: String?
    
    @State private var selectedItem = ""
    @State private var showBottomSheet = false
    @State private var errorMessage: String? = nil
    
    private func saveGeneration() {
        guard let top10 = top10 else { return }
        UserDefaults.standard.set(top10, forKey: UserDefaultsKeys.generatedListPrefix + category!)
        dismiss()
    }
    
    private func addItem() {
        // Can't add more than 10 items
        // Can't repeat items
        
        if top10?.count == 10 {
            withAnimation {
                errorMessage = "You can't add more than 10 items"
            }
            return
        }
        
        // Find an "Item X" that doesn't exist
        var newItem = "Item 1"
        var index = 1
        while top10?.contains(newItem) == true {
            index += 1
            newItem = "Item \(index)"
        }
        
        if top10?.contains(newItem) == true {
            withAnimation {
                errorMessage = "You can't repeat items"
            }
            return
        }
        
        withAnimation {
            top10?.append(newItem)
            errorMessage = nil
        }
    }
    
    var body: some View {
        
        if entitlementManager.userTier == .none {
            VStack {
                Text("You need to be a Pro or Premium user to access this feature")
                    .padding()
                    .foregroundColor(.red)
                
                Button(action: { dismiss() }) {
                    Text("Dismiss")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        else {
            VStack {
                List {
                    // Top 10 items
                    ForEach(top10!, id: \.self) { item in
                        Text(item)
                            .transition(.move(edge: .top))
                            .animation(.default, value: top10)
                            .swipeActions(edge: .trailing) {
                                Button(action: {
                                    selectedItem = item
                                    showBottomSheet.toggle()
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
                    
                    // Add another item button
                    Section {
                        Button(action: addItem) {
                            HStack {
                                Spacer()
                                Text("Add Another Item")
                                Spacer()
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .sheet(isPresented: $showBottomSheet) {
                    TopTenItemOptionsBottomSheetView(item: $selectedItem, top10: $top10, showBottomSheet: $showBottomSheet)
                        .presentationDetents([.height(150)])
                }
                
                if errorMessage != nil {
                    Text(errorMessage!)
                        .padding(.top)
                        .padding(.horizontal)
                        .foregroundColor(.red)
                }
                
                Button(action: saveGeneration) {
                    Text("Save")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle(category!)
            .onChange(of: errorMessage) {
                if errorMessage == nil { return }
                
                Task {
                    vibrate()
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    withAnimation { errorMessage = nil }
                }
            }
        }
    }
}

// MARK: - TopTenItemOptionsBottomSheetView

struct TopTenItemOptionsBottomSheetView: View {
    
    @Binding var item: String
    @Binding var top10: [String]?
    @Binding var showBottomSheet: Bool
    
    @State private var newItemName = ""
    @FocusState private var textFieldFocus: Bool
    
    private func saveRename() {
        if let index = top10?.firstIndex(of: item) {
            withAnimation {
                top10?[index] = newItemName
            }
            showBottomSheet.toggle()
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Button(action: { showBottomSheet.toggle() }) {
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
            .padding(.bottom)
            
            Spacer()
            
            TextField("Rename item", text: $newItemName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($textFieldFocus)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .onAppear {
            newItemName = item
            textFieldFocus = true
        }
    }
}

// MARK: - Preview

#Preview("Pro-$0") {
    Preview(userTier: .pro, incurredCost: 0)
}

#Preview("None-$0") {
    Preview(userTier: .none, incurredCost: 0)
}

private struct Preview: View {
    
    let userTier: UserTier
    let incurredCost: Double
    
    
    @State var top10: [String]? = ["Item 1", "Item 2", "Item 3", "Item 4", "Item 5", "Item 6", "Item 7", "Item 8", "Item 9"]
    @State var category: String? = "GenCategory"
    
    init(userTier: UserTier, incurredCost: Double) {
        self.userTier = userTier
        self.incurredCost = incurredCost
    }
    
    var body: some View {
        WithManagers(userTier: userTier, incurredCost: incurredCost) {
            GeneratedCategoryView(top10: $top10, category: $category)
        }
    }
}
