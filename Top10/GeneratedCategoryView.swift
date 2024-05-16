//
//  GeneratedCategoryView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

import SwiftUI

struct GeneratedCategoryView: View {
    
    @Binding var top10: [String]?
    @Binding var category: String?
    
    @State private var selectedItem = ""
    @State private var showBottomSheet = false
    
    private func handleSaveGeneration() {
        guard let top10 = top10 else { return }
        UserDefaults.standard.set(top10, forKey: UserDefaultsKeys.generatedListPrefix + category!)
    }
    
    var body: some View {
        VStack {
            List {
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
                        }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .sheet(isPresented: $showBottomSheet) {
                TopTenItemOptionsBottomSheetView(item: $selectedItem, top10: $top10, showBottomSheet: $showBottomSheet)
                    .presentationDetents([.height(200), .medium])
            }
            
            Button(action: handleSaveGeneration) {
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
    }
}

struct TopTenItemOptionsBottomSheetView: View {
    
    @Binding var item: String
    @Binding var top10: [String]?
    @Binding var showBottomSheet: Bool
    
    @State private var newItemName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                TextField("Rename Item", text: $newItemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
                
                Button(action: {
                    if let index = top10?.firstIndex(of: item) {
                        withAnimation {
                            top10?[index] = newItemName
                        }
                        showBottomSheet.toggle()
                    }
                }) {
                    Text("Rename")
                        .bold()
                }
                .padding(.leading)
            }

            Spacer()
            
            Button(role: .destructive, action: {
                withAnimation { 
                    top10?.removeAll(where: { $0 == item })
                }
                showBottomSheet.toggle()
            }) {
                Text("Delete")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.red)
                    .foregroundColor(.white)
            }
            .cornerRadius(10)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(20)
        .onAppear {
            newItemName = item
        }
        .padding()
    }
}

#Preview {
    struct Preview: View {
        @State var top10: [String]? = ["Item 1", "Item 2", "Item 3"]
        @State var category: String? = "GenCategory"
        var body: some View {
            GeneratedCategoryView(top10: $top10, category: $category)
        }
    }
    
    return Preview()
}
