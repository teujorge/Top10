//
//  Constants.swift
//  Top10
//
//  Created by Matheus Jorge on 5/15/24.
//

enum LottieAnimations {
    static let logoAnimation = "LogoAnimation"
}

enum UserDefaultsKeys {
    static let userTier = "userTier"
    static let fundTransactions = "fundTransactions"
    static let generatedListPrefix = "generatedList-"
}

enum UserTier: String {
    case pro
    case premium
    case none
}

enum ProductID {
    static let pro = "me.mjorge.topten.sub.pro"
    static let premium = "me.mjorge.topten.sub.premium"
}
