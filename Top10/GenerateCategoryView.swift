//
//  GenerateCategoryView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI

struct GenerateCategoryView: View {

    @State private var top10: [String]? // This will be the list of top 10 items
    @State private var category: String? // This will be the category name
    @State private var categoryText: String = "" // This is the textfield text
    @State private var isLoading = false // Shows if OpenAI is generating
    @State private var shouldNavigateToGeneratedCategoryView = false
    
    private func handleGeneration() {
        guard !categoryText.isEmpty else { return }
        
        Task {
            withAnimation { isLoading = true }
            
            top10 = await generateTopTen(categoryText)
            if top10 != nil {
                withAnimation {
                    category = categoryText
                    shouldNavigateToGeneratedCategoryView = true
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
            }
            
            NavigationLink(
                destination: GeneratedCategoryView(top10: $top10, category: $category),
                isActive: $shouldNavigateToGeneratedCategoryView,
                label: { EmptyView() }
            )
        }
        .navigationTitle("Generator")
    }
}

#Preview {
    GenerateCategoryView()
}
