import UIKit

extension UIApplication {
    var visibleViewController: UIViewController? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        guard let rootViewController = appDelegate.window?.rootViewController else { return nil }
        return getVisibleViewController(rootViewController)
    }
    
    private func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }
        
        if let navigationController = rootViewController as? UINavigationController {
            return navigationController.visibleViewController
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            return tabBarController.selectedViewController
        }
        
        return rootViewController
    }
}
