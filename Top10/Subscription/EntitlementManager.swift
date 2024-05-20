//
//  EntitlementManager.swift
//  Top10
//
//  Created by Matheus Jorge on 5/17/24.
//

import SwiftUI

struct FundTransaction: Codable, Equatable {
    var used: Double
    var expired: Double
    
    let amount: Double
    let timestamp: Date
    
    init(amount: Double, timestamp: Date = .now) {
        self.used = 0
        self.expired = 0
        self.amount = amount
        self.timestamp = timestamp
    }
    
    static func ==(lhs: FundTransaction, rhs: FundTransaction) -> Bool {
        return lhs.amount == rhs.amount && lhs.timestamp == rhs.timestamp
    }
}

class EntitlementManager: ObservableObject {
    @Published var userTier: UserTier = .none
    @Published var fundTransactions: [FundTransaction] = [] {
        didSet { transactionsDidUpdate() }
    }
    @Published var isUserDisabled: Bool = false
    
    func addFunds(_ amount: Double) {
        let transaction = FundTransaction(amount: amount)
        DispatchQueue.main.async {
            self.fundTransactions.append(transaction)
            print("Added funds: \(amount)")
            print("Available funds: \(self.calculateAvailableFunds())")
        }
    }
    
    func incurCost(_ amount: Double) {
        var remainingCost = amount
        
        DispatchQueue.main.async {
            for var transaction in self.fundTransactions.sorted(by: { $0.timestamp < $1.timestamp }) {
                if remainingCost <= 0 {
                    break
                }
                
                let availableAmount = transaction.amount - transaction.used
                if availableAmount > remainingCost {
                    transaction.used += remainingCost
                    remainingCost = 0
                } else {
                    remainingCost -= availableAmount
                    transaction.used = transaction.amount
                }
            }
            
            print("Incurred cost: \(amount)")
            print("Available funds: \(self.calculateAvailableFunds())")
        }
    }
    
    func updateUser(userTier: UserTier, productPrice: Double) {
        DispatchQueue.main.async {
            print("Current user tier: \(self.userTier.rawValue)")
            self.userTier = userTier
            self.addFunds(productPrice)
            print("Updated user tier: \(userTier.rawValue)")
        }
    }
    
    func calculateAvailableFunds() -> Double {
        return fundTransactions.reduce(0) { $0 + ($1.amount - $1.used - $1.expired) }
    }
    
    private func transactionsDidUpdate() {
        let now = Date()
        let expiredTransactions = fundTransactions.filter { now.timeIntervalSince($0.timestamp) > 60 * 60 * 24 * 60 }
        
        DispatchQueue.main.async {
            for var transaction in self.fundTransactions {
                if expiredTransactions.contains(transaction) {
                    transaction.expired = transaction.amount - transaction.used
                }
            }
            
            self.saveTransactions()
            self.isUserDisabled = self.calculateAvailableFunds() <= 0
        }
    }
    
    private func saveTransactions() {
        do {
            let data = try JSONEncoder().encode(fundTransactions)
            UserDefaults.standard.set(data, forKey: UserDefaultsKeys.fundTransactions)
        } catch {
            print("Failed to save transactions: \(error)")
        }
    }
    
    private func loadTransactions() -> [FundTransaction] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.fundTransactions) else { return [] }
        do {
            let transactions = try JSONDecoder().decode([FundTransaction].self, from: data)
            return transactions
        } catch {
            print("Failed to load transactions: \(error)")
            return []
        }
    }
}
