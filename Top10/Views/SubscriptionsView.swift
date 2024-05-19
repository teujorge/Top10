//
//  SubscriptionsView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/17/24.
//

import SwiftUI
import StoreKit

// MARK: SubscriptionsView

struct SubscriptionsView: View {
    
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    
    @State private var selectedProduct: Product? = nil
    private let features: [String] = [
        "Remove all ads",
        "Access to speech",
        // "Play with friends in multiplayer mode",
        "Pro: 10+ hours",
        "Premium: 20+ hours",
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                accessTitle
                featuresView
                 if !subscriptionsManager.products.isEmpty {
                    productsView
                } else {
                    ProgressView()
                        .padding()
                }
                purchaseSection
                
            }
        }
        .onAppear {
            Task {
                await subscriptionsManager.loadProducts()
            }
        }
    }
    
    // MARK: - Views
    
    private var accessTitle: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(systemName: "dollarsign.circle.fill")
                .padding()
                .foregroundStyle(.tint)
                .font(Font.system(size: 80))
            
            Text("Unlock True Power")
                .font(.system(size: 33.0, weight: .bold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
            
            Text("Get access to all of our features")
                .font(.system(size: 17.0, weight: .semibold))
                .fontDesign(.rounded)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
        }
        .padding()
    }
    
    private var featuresView: some View {
        VStack {
            ForEach(features, id: \.self) { feature in
                HStack(alignment: .center) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 22.5, weight: .medium))
                        .foregroundStyle(.blue)
                    
                    Text(feature)
                        .font(.system(size: 17.0, weight: .semibold, design: .rounded))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.vertical, 0)
                .frame(height: 20, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            .padding(.top, 10)
        }
        .padding()
    }
    
    private var productsView: some View {
        VStack{
            ForEach(subscriptionsManager.products, id: \.self) { product in
                SubscriptionItemView(product: product, selectedProduct: $selectedProduct)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var purchaseSection: some View {
        VStack(alignment: .center) {
            // Restore Purchases Button
            Button("Restore Purchases") {
                Task {
                    await subscriptionsManager.restorePurchases()
                }
            }
            .font(.system(size: 14.0, weight: .regular, design: .rounded))
            .frame(alignment: .center)
            
            // Purchase Button
            Button(action: {
                if let selectedProduct = selectedProduct {
                    Task {
                        await subscriptionsManager.buyProduct(selectedProduct)
                    }
                } else {
                    print("Please select a product before purchasing.")
                }
            }) {
                Text(selectedProduct == nil ? "Select a Subscription" : "Purchase \(selectedProduct!.displayName)")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(selectedProduct == nil ? .gray : .blue)
                    .foregroundStyle(.white)
                    .font(.system(size: 16.5, weight: .semibold, design: .rounded))
            }
            .cornerRadius(10)
            .padding(.vertical)
            .disabled(selectedProduct == nil)
        }
        .padding()
    }
}

// MARK: Subscription Item
struct SubscriptionItemView: View {
    var product: Product
    @Binding var selectedProduct: Product?
    
    var body: some View {
        Button(action: {
            withAnimation { selectedProduct = product }
        }) {
            ZStack {
                HStack {
                    VStack(alignment: .leading, spacing: 8.5) {
                        Text(product.displayName)
                            .font(.system(size: 16.0, weight: .semibold, design: .rounded))
                            .multilineTextAlignment(.leading)
                        
                        Text("Get access for just \(product.displayPrice)")
                            .font(.system(size: 14.0, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Image(systemName: selectedProduct == product ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(selectedProduct == product ? .blue : .gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(selectedProduct == product ? Color.blue : Color.gray, lineWidth: 1)
                )
            }
            .contentShape(Rectangle()) // Make the entire ZStack tappable
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.vertical, 5)
        .cornerRadius(10)
        .listRowSeparator(.hidden)
    }
}

// MARK: - Previews

#Preview {
    WithManagers {
        SubscriptionsView()
    }
}
