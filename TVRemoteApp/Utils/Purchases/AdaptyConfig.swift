import Adapty

struct AdaptyConfig: Decodable {
    var trial: String?
    var priceSubtitle: String
    var priceDescription: String
    var purchaseTitle: String
    var descriptionSubtitle: String
    var descriptionPerWeek: String
    var review: Bool
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
            return "onboarding_paywall"
        }
    }
}
