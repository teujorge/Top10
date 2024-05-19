//
//  EntitlementManager.swift
//  Top10
//
//  Created by Matheus Jorge on 5/17/24.
//

import SwiftUI
import Combine

struct FundTransaction: Equatable {
    let amount: Double
    let timestamp: Date
    
    static func ==(lhs: FundTransaction, rhs: FundTransaction) -> Bool {
        return lhs.amount == rhs.amount && lhs.timestamp == rhs.timestamp
    }
}


class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "group.subscriptions.topten")!
    
    @AppStorage("userTier", store: userDefaults)
    private var storedUserTier: String = UserTier.none.rawValue
    
    @Published var userTier: UserTier
    
    @Published var fundTransactions: [FundTransaction] = [] {
        didSet { updateFunds() }
    }
    
    @Published var isUserDisabled: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Temporary initialization
        self.userTier = UserTier.none
        
        // Initialize other properties
        let initialUserTier = UserTier(rawValue: storedUserTier) ?? .none
        self.userTier = initialUserTier
        
        print("EntitlementManager initialized!")
        print("User tier: \(userTier.rawValue)")
        print("Available funds: \(calculateAvailableFunds())")
    }
    
    func addFunds(amount: Double) {
        let transaction = FundTransaction(amount: amount, timestamp: Date())
        fundTransactions.append(transaction)
        print("Added funds: \(amount)")
        print("Available funds: \(calculateAvailableFunds())")
    }
    
    func incurCost(_ amount: Double) {
        var remainingCost = amount
        var updatedTransactions: [FundTransaction] = []
        
        for transaction in fundTransactions {
            if remainingCost <= 0 {
                updatedTransactions.append(transaction)
            } else if transaction.amount > remainingCost {
                let updatedTransaction = FundTransaction(amount: transaction.amount - remainingCost, timestamp: transaction.timestamp)
                updatedTransactions.append(updatedTransaction)
                remainingCost = 0
            } else {
                remainingCost -= transaction.amount
            }
        }
        
        fundTransactions = updatedTransactions
        print("Incurred cost: \(amount)")
        print("Available funds: \(calculateAvailableFunds())")
    }
    
    func updateUser(userTier: UserTier, productPrice: Double) {
        DispatchQueue.main.async {
            print("Current user tier: \(self.userTier.rawValue)")
            self.userTier = userTier
            self.addFunds(amount: productPrice)
            print("Updated user tier: \(userTier.rawValue)")
        }
    }
    
    func calculateAvailableFunds() -> Double {
        return fundTransactions.reduce(0) { $0 + $1.amount }
    }
    
    private func updateFunds() {
        let now = Date()
        let filteredTransactions = fundTransactions.filter { now.timeIntervalSince($0.timestamp) <= 60 * 60 * 24 * 60 }
        
        // Only update fundTransactions if there is a change
        if filteredTransactions != fundTransactions {
            fundTransactions = filteredTransactions
        }
        
        isUserDisabled = calculateAvailableFunds() <= 0
    }

}
