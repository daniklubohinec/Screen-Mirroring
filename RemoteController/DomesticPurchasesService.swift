//
//  DomesticPurchasesService.swift
//  RemoteController
//
//  Created by Enis Maresch on 03/02/2025.
//

import UIKit
import Adapty

struct AdaptyConfig: Decodable {
    var onReview: Bool
}

struct PaywallModel {
    var config: AdaptyConfig
    var products: [AdaptyPaywallProduct]
}

protocol PurchaseServiceProtocol {
    
    var hasPremium: Bool { get }
    var paywallsLoaded: Bool { get }
    var inAppPaywall: PaywallModel? { get }
    
    func configure()
    func getPaywalls() async
    func checkPurchases() async
    func makePurchase(product: AdaptyPaywallProduct) async
    func restorePurchases() async
}

enum PurchaseInfo {
    case onboardingInapp
    
    var key: String {
        switch self {
        case .onboardingInapp:
            return "premium_access"
        }
    }
}

final class DomesticPurchasesService: PurchaseServiceProtocol {
    static let shared = DomesticPurchasesService()
    
    @Published var hasPremium: Bool = false
    @Published var inAppPaywall: PaywallModel?
    var paywallsLoaded: Bool {
        inAppPaywall != nil
    }
    var review: Bool {
        return inAppPaywall?.config.onReview ?? false
    }
    
    private init() { }
    
    func configure() {
        Adapty.delegate = self
        Adapty.activate("public_live_OJuVh9dC.LevBNMx6EbufJWWq9txG")
        Task {
            await checkPurchases()
            await getPaywalls()
        }
    }
    
    @MainActor
    func checkPurchases() async {
        do {
            let profile = try await Adapty.getProfile()
            hasPremium = profile.accessLevels["premium"]?.isActive ?? false
        } catch {
            hasPremium = false
        }
    }
    
    func getPaywalls() async {
        do {
            let inAppPaywall = try await Adapty.getPaywall(placementId: PurchaseInfo.onboardingInapp.key)
            let inAppData = retrievePaywalls(paywall: inAppPaywall)
            
            guard let inAppData else { return }
            try await getPaywallProducts(paywall: inAppPaywall, data: inAppData, type: .onboardingInapp)
        } catch { }
    }
    
    private func retrievePaywalls(paywall: AdaptyPaywall) -> Data? {
        guard let json = paywall.remoteConfig,
              let inAppData = json.jsonString.data(using: .utf8) else { return nil }
        return inAppData
    }
    
    private func getPaywallProducts(paywall: AdaptyPaywall,
                                    data: Data,
                                    type: PurchaseInfo) async throws {
        
        let config = try JSONDecoder().decode(AdaptyConfig.self, from: data)
        inAppPaywall = PaywallModel(config: config, products: [])
        let products: [AdaptyPaywallProduct] = try await Adapty.getPaywallProducts(paywall: paywall)
        switch type {
        case .onboardingInapp:
            inAppPaywall = PaywallModel(config: config, products: products)
        }
    }
    
    func makePurchase(product: AdaptyPaywallProduct) async {
        do {
            let result = try await Adapty.makePurchase(product: product)
            hasPremium = (result.profile.accessLevels["premium"]?.isActive == true)
        } catch {
            hasPremium = false
        }
    }
    
    func restorePurchases() async {
        do {
            let profile = try await Adapty.restorePurchases()
            hasPremium = (profile.accessLevels["premium"]?.isActive == true)
        } catch {
            hasPremium = false
        }
    }
}

extension DomesticPurchasesService: AdaptyDelegate {
    func didLoadLatestProfile(_ profile: AdaptyProfile) {
        hasPremium = profile.accessLevels["premium"]?.isActive ?? false
    }
}
