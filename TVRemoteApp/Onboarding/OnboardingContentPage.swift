import UIKit

enum OnboardingPage: Int, CaseIterable {
    case firstScreen
    case secondScreen
    case thirdScreen
    case fourthScreen
    
    var image: UIImage? {
        switch self {
        case .firstScreen:
            return UIImage(named: "firstOnboardingImage")
        case .secondScreen:
            return UIImage(named: "secondOnboardingImage")
        case .thirdScreen:
            return UIImage(named: "thirdOnboardingImage")
        case .fourthScreen:
            return UIImage(named: "fourthOnboardingImage")
        }
    }
    
    var title: String {
        switch self {
        case .firstScreen:
            return "Universal TV Remote"
        case .secondScreen:
            return "Easily access and enjoy TV content"
        case .thirdScreen:
            return "Cast Any Content from Your iPhone"
        case .fourthScreen:
            return "Get Full Access to All Features"
        }
    }
    var subtitle: String {
        switch self {
        case .firstScreen:
            return "Control your smart TV effortlessly from your phone for easy navigation."
        case .secondScreen:
            return "Seamless touchpad navigation and fast, responsive keyboard input."
        case .thirdScreen:
            return "Effortlessly stream photos, videos, music, web content, and more with a single click."
        case .fourthScreen:
            return "Unlimited TV remote and screen mirroring with a 3-day free trial, then $6.99 per week."
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
