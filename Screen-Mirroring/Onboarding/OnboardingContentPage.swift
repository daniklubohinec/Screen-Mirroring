import UIKit

enum OnboardingPage: Int, CaseIterable {
    case firstScreen
    case secondScreen
    case thirdScreen
    case fourthScreen
    
    var image: UIImage? {
        switch self {
        case .firstScreen:
            return UIImage(named: "firstScreenImage")
        case .secondScreen:
            return UIImage(named: "secondScreenImage")
        case .thirdScreen:
            return UIImage(named: "thirdScreenImage")
        case .fourthScreen:
            return UIImage(named: "firstScreenImage")
        }
    }
    
    var title: String {
        switch self {
        case .firstScreen:
            return "Stream Any Content from Your iPhone"
        case .secondScreen:
            return "Real-time Screen Mirroring"
        case .thirdScreen:
            return "Effortless Universal Connectivity"
        case .fourthScreen:
            return PurchaseService.shared.review ? "Unlimited Screen Mirroring" : "Project Your iPhone to a Larger Screen"
        }
    }
    var subtitle: String {
        switch self {
        case .firstScreen:
            return "Effortlessly stream photos, videos, music, web content, and more with a single click."
        case .secondScreen:
            return "Instantly stream any content from your iPhone to your big TV screen."
        case .thirdScreen:
            return "Seamlessly link your iPhone to any device for smooth and uninterrupted screen mirroring."
        case .fourthScreen:
            return "Unlimited Screen Mirroring with a 3-day free trial, then $6.99 per week."
        }
    }
    var showPriceOptions: Bool {
        switch self {
        case .firstScreen, .secondScreen, .thirdScreen:
            return false
        case .fourthScreen:
            return true
        }
    }
}
