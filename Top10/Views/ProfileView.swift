//
//  ProfileView.swift
//  Top10
//
//  Created by Matheus Jorge on 5/19/24.
//

import SwiftUI
import StoreKit

struct ProfileView: View {
    
    @EnvironmentObject var entitlementManager: EntitlementManager
    @EnvironmentObject var subscriptionManager: SubscriptionsManager
    
    private func showManageSubscriptions() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        Task {
            do {
                try await AppStore.showManageSubscriptions(in: windowScene)
            } catch {
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
                        Text(entitlementManager.userTier.rawValue.capitalized)
                    }
                    HStack {
                        Text("Available Funds:")
                        Spacer()
                        Text("$\(entitlementManager.calculateAvailableFunds(), specifier: "%.2f")")
                    }
                    HStack {
                        Text("User Disabled:")
                        Spacer()
                        Text(entitlementManager.isUserDisabled ? "Yes" : "No")
                            .foregroundColor(entitlementManager.isUserDisabled ? .red : .green)
                    }
                }
                .padding()
                
                // Fund Transactions
                Section(header: Text("Transactions").font(.headline)) {
                    List(entitlementManager.fundTransactions, id: \.timestamp) { transaction in
                        VStack(alignment: .leading) {
                            Text("Amount: $\(transaction.amount, specifier: "%.2f")")
                            Text("Date: \(transaction.timestamp, formatter: transactionDateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                
                // Actions
                Section(header: Text("Actions").font(.headline)) {
                    // Purchase subscriptions
                    if entitlementManager.userTier == .none {
                        NavigationLink(destination: SubscriptionsView()) {
                            Text("Subscribe Now")
                                .foregroundColor(.blue)
                        }
                    }
                    // Manage subscriptions
                    else {
                        Button(action: showManageSubscriptions) {
                            Text("Manage Subscription")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    // Add funds
                    if entitlementManager.calculateAvailableFunds() < 10 {
                        Button(action: {
                            entitlementManager.addFunds(10)
                        }) {
                            Text("DEV: Add $10")
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
    
    private var transactionDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}

// MARK: Preview

#Preview("Pro EnabledUser") {
    WithManagers {
        ProfileView()
    }
}

#Preview("Pro DisabledUser") {
    WithManagers(fundTransactions: []) {
        ProfileView()
    }
}
