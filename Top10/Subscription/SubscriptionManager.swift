//
//  SubscriptionsManager.swift
//  Top10
//
//  Created by Matheus Jorge on 5/17/24.
//

import StoreKit

@MainActor
class SubscriptionsManager: NSObject, ObservableObject {
    let productIDs: [String] = [ProductID.pro, ProductID.premium]
    var purchasedSubscription: Product?
    
    @Published var products: [Product] = []
    
    private var entitlementManager: EntitlementManager? = nil
    private var updates: Task<Void, Never>? = nil
    
    init(entitlementManager: EntitlementManager) {
        self.entitlementManager = entitlementManager
        super.init()
        self.updates = observeTransactionUpdates()
        SKPaymentQueue.default().add(self)
        
        print("SubscriptionsManager initialized!")
        print("Purchased subscription: \(purchasedSubscription?.displayName ?? "nil")")
        print("Products: \(products)")
    }
    
    deinit {
        updates?.cancel()
    }
    
    func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await _ in Transaction.updates {
                await self.updatePurchasedProducts()
            }
        }
    }
}

// MARK: StoreKit2 API
extension SubscriptionsManager {
    func loadProducts() async {
        do {
            self.products = try await Product.products(for: productIDs)
                .sorted(by: { $1.price > $0.price })
            print("Products loaded: \(products)")
        } catch {
            print("Failed to fetch products!")
        }
    }
    
    func buyProduct(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            print("Purchase result: \(result)")
            
            switch result {
            case let .success(.verified(transaction)):
                // Successful purchase
                await transaction.finish()
                await self.updatePurchasedProducts()
                return true
            case let .success(.unverified(_, error)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                print("Unverified purchase. Might be jailbroken. Error: \(error)")
                break
            case .pending:
                // Transaction waiting on SCA (Strong Customer Authentication) or
                // approval from Ask to Buy
                break
            case .userCancelled:
                print("User cancelled!")
                break
            @unknown default:
                print("Failed to purchase the product!")
                break
            }
        } catch let error {
            print("Failed to purchase the product: \(error)")
        }
        
        return false
    }
    
    func updatePurchasedProducts() async {
        for await result in Transaction.currentEntitlements {

            print("---")
            print(result)
            print("---")
            
            guard case .verified(let transaction) = result else {
                continue
            }
            
            print("Transaction---: \(transaction)")
            
            if transaction.revocationDate == nil {
                print("Transaction is not revoked")
                self.purchasedSubscription = products.first(where: { $0.id == transaction.productID })
            } else {
                print("Transaction is revoked")
                self.purchasedSubscription = nil
            }
            print("Purchased subscription: \(purchasedSubscription?.displayName ?? "nil")")
        }
        
        updateEntitlements()
    }
    
    func updateEntitlements() {
        print("SubscriptionManager -> Updating entitlements...")
        
        print("Purchased subscription---: \(String(describing: purchasedSubscription))")
        
        if let purchasedSubscription = purchasedSubscription {
            entitlementManager?.updateUser(
                userTier: purchasedSubscription.id == ProductID.premium ? .premium : .pro,
                productPrice: NSDecimalNumber(decimal: purchasedSubscription.price).doubleValue
            )
        } else {
            entitlementManager?.updateUser(userTier: .none, productPrice: 0.0)
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            print(error)
        }
    }
}

extension SubscriptionsManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
}
