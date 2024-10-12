import UIKit

enum OnboardingPage: Int, CaseIterable {
    case first
    case second
    case third
    case fourth
    
    var image: UIImage? {
        switch self {
        case .first:
            return R.image.onboardingScreen.first()
        case .second:
            return R.image.onboardingScreen.second()
        case .third:
            return R.image.onboardingScreen.third()
        case .fourth:
            return R.image.onboardingScreen.fourth()
        }
    }
    
    var title: String {
        switch self {
        case .first:
            return "Universal TV Remote"
        case .second:
            return "Easily access and enjoy TV content"
        case .third:
            return "Cast Any Content from Your iPhone"
        case .fourth:
            return "Get Full Access to All Features"
        }
    }
    var subtitle: String {
        switch self {
        case .first:
            return "Control your smart TV effortlessly from your phone for easy navigation."
        case .second:
            return "Seamless touchpad navigation and fast, responsive keyboard input."
        case .third:
            return "Effortlessly stream photos, videos, music, web content, and more with a single click."
        case .fourth:
            return "Unlimited TV remote and screen mirroring with a 3-day free trial, then $6.99 per week."
        }
    }
    var showPriceOptions: Bool {
        switch self {
        case .first, .second, .third:
            return false
        case .fourth:
            return true
        }
    }
}
