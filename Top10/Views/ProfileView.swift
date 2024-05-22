//
//  ProfileView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/19/24.
//

import SwiftUI
import StoreKit

struct ProfileView: View {
    @EnvironmentObject var userData: UserData
    
    @State private var showSubscriptionSheet = false
    
    private func showManageSubscriptions() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        Task {
            do {
                try await AppStore.showManageSubscriptions(in: windowScene, subscriptionGroupID: subGroupID)
            } catch {
                showSubscriptionSheet = true
                print("Error showing manage subscriptions: \(error)")
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                // User Information
                Section(header: Text("User Information").font(.headline)) {
                    HStack {
                        Text("Current Tier:")
                        Spacer()
                        Text(userData.tier.rawValue.capitalized)
                    }
                }
                .padding()
                
                // Subscriptions
                if userData.tier == .none {
                    Button(action: {
                        showSubscriptionSheet = true
                    }) {
                        Text("Subscribe")
                            .foregroundColor(.blue)
                    }
                } else {
                    Button(action: showManageSubscriptions) {
                        Text("Manage Subscriptions")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Profile")
        }
        .sheet(isPresented: $showSubscriptionSheet) {
            SubscriptionStoreView(groupID: subGroupID)
                .subscriptionStorePickerItemBackground(.ultraThinMaterial)
        }
        .onInAppPurchaseCompletion { product, result in
            switch result {
            case .success:
                print("ProfileView: Purchase completed: \(product.displayName)")
                showSubscriptionSheet = false
            case .failure(let error):
                print("ProfileView: Purchase failed: \(error)")
            }
        }
    }
}

// MARK: Preview

#Preview {
    ProfileView()
        .environmentObject(UserData())
}
