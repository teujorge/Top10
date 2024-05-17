//
//  EntitlementManager.swift
//  Top10
//
//  Created by Matheus Jorge on 5/17/24.
//

import SwiftUI
import Combine

class EntitlementManager: ObservableObject {
    static let userDefaults = UserDefaults(suiteName: "group.subscriptions.topten")!
    
    @AppStorage("userTier", store: userDefaults)
    private var storedUserTier: String = UserTier.none.rawValue
    
    @Published var userTier: UserTier
    
    @AppStorage("incurredCost", store: userDefaults)
    var incurredCost: Double = 0.0
    
    @AppStorage("lastResetTimestamp", store: userDefaults)
    private var lastResetTimestamp: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Temporary initialization
        self.userTier = UserTier.none
        
        // Initialize other properties
        let initialUserTier = UserTier(rawValue: storedUserTier) ?? .none
        self.userTier = initialUserTier
        
        // Check monthly reset
        resetMonthlyCostIfNeeded()
        
        print("EntitlementManager initialized!")
        print("User tier: \(userTier.rawValue)")
        print("Incurred cost: \(incurredCost)")
    }
    
    private func resetMonthlyCostIfNeeded() {
        let now = Date().timeIntervalSince1970
        if lastResetTimestamp > 0 {
            #if DEBUG
            if (now - lastResetTimestamp) >= 60 {
                resetMonthlyCost()
            }
            #else
            if (now - lastResetTimestamp) >= 60 * 60 * 24 * 30 {
                resetMonthlyCost()
            }
            #endif
        } else {
            print("First time setting up monthly cost")
            lastResetTimestamp = now
        }
    }
    
    private func resetMonthlyCost() {
        DispatchQueue.main.async {
            self.incurredCost = 0.0
            self.lastResetTimestamp = Date().timeIntervalSince1970
            print("Monthly cost reset!")
        }
    }
    
    func updateUserTier(_ newTier: UserTier) {
        DispatchQueue.main.async {
            print("Current user tier: \(self.userTier.rawValue)")
            self.userTier = newTier
            print("Updated user tier: \(newTier.rawValue)")
        }
    }
    
    func addCost(_ amount: Double) {
        DispatchQueue.main.async {
            print("Adding cost: \(amount)")
            self.incurredCost += amount
            print("New incurred cost: \(self.incurredCost)")
        }
    }
}
