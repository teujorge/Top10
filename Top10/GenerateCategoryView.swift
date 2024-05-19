//
//  GenerateCategoryView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI

struct GenerateCategoryView: View {
    
    @EnvironmentObject private var entitlementManager: EntitlementManager

    @State private var top10: [String]? // This will be the list of top 10 items
    @State private var category: String? // This will be the category name
    @State private var categoryText: String = "" // This is the textfield text
    @State private var isLoading = false // Shows if OpenAI is generating
    @State private var presentGeneratedCategoryView = false
    
    @FocusState private var isTextFieldFocused: Bool
    
    private func handleGeneration() {
        
        if entitlementManager.userTier == .none {
            return
        }
        
        guard !categoryText.isEmpty else { return }
        
        Task {
            withAnimation { isLoading = true }
            
            top10 = await generateTopTen(category: categoryText, entitlementManager: entitlementManager)
            if top10 != nil {
                withAnimation {
                    category = categoryText
                    presentGeneratedCategoryView = true
                }
            }
            else {
                withAnimation { category = nil }
            }
            
            withAnimation { isLoading = false }
        }
    }
    
    var body: some View {
        VStack {
            Text("You will generate a top 10 list for the category: '\(categoryText.isEmpty ? "--" : categoryText)'")
                .padding()
                .font(.headline)
            
            Spacer()
            
            TextField("Enter a category", text: $categoryText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused($isTextFieldFocused)
                .padding(.horizontal)
                .padding(.bottom)
            
            if isLoading {
                ProgressView()
                    .padding(.vertical, 24)
            }
            else {
                Button(action: handleGeneration) {
                    Text("Generate Top 10")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                }
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom)
                .alert(isPresented: entitlementManager.userTier == .none ? .constant(true) : .constant(false)) {
                    Alert(
                        title: Text("Subscription Required"),
                        message: Text("To generate a list, you need to be subscribed to our service."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
        }
        .navigationTitle("Generator")
        .navigationDestination(isPresented: $presentGeneratedCategoryView) {
            GeneratedCategoryView(top10: $top10, category: $category)
        }
        .onAppear() {
            isTextFieldFocused = true
        }
    }
}

// MARK: - Preview

#Preview("Pro-$100") {
    WithManagers(userTier: .pro, incurredCost: 100) {
        GenerateCategoryView()
    }
}

#Preview("None-$0") {
    WithManagers(userTier: .none, incurredCost: 0) {
        GenerateCategoryView()
    }
}
