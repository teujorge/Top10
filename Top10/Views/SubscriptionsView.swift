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
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var entitlementManager: EntitlementManager
    @EnvironmentObject private var subscriptionsManager: SubscriptionsManager
    
    @State private var isPurchaseButtonLoading = false
    
    @State private var showAlert = false
    @State private var alertText: String? {
        didSet {
            if alertText != nil { showAlert = true }
        }
    }
    
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
                }
                else {
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
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Subscription Error"),
                message: Text(alertText ?? "An error occurred. Please try again later."),
                dismissButton: .default(Text("OK"))
            )
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
        .disabled(isPurchaseButtonLoading)
        .animation(.easeInOut, value: isPurchaseButtonLoading)
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
            .disabled(isPurchaseButtonLoading)
            .animation(.easeInOut, value: isPurchaseButtonLoading)
            
            // Purchase Button
            Button(action: {
                if selectedProduct == nil {
                    alertText = "Please select a product before purchasing."
                }
                else {
                    Task {
                        DispatchQueue.main.async {
                            withAnimation { isPurchaseButtonLoading = true }
                        }
                        let purchased = await subscriptionsManager.buyProduct(self.selectedProduct!)
                        DispatchQueue.main.async {
                            withAnimation { isPurchaseButtonLoading = false }
                            if purchased { dismiss() }
                        }
                    }
                }
            }) {
                if isPurchaseButtonLoading {
                    ProgressView()
                        .padding()
                }
                else {
                    Text(selectedProduct == nil ? "Select a Subscription" : "Purchase \(selectedProduct!.displayName)")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(selectedProduct == nil ? .gray : .blue)
                        .foregroundStyle(.white)
                        .font(.system(size: 16.5, weight: .semibold, design: .rounded))
                }
            }
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.bottom)
            .padding(.top, 5)
            .disabled(selectedProduct == nil || isPurchaseButtonLoading)
            .animation(.easeInOut, value: isPurchaseButtonLoading)
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

// MARK: Previews

#Preview {
    WithManagers {
        SubscriptionsView()
    }
}
