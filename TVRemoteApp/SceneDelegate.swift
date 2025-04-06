import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var enteredInBackground = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        let splashScreenViewController = R.storyboard.splashScreen.instantiateInitialViewController()
        window?.rootViewController = splashScreenViewController
        window?.makeKeyAndVisible()
        PurchaseService.shared.configure()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if enteredInBackground {
            defer { enteredInBackground = false }
            guard !PurchaseService.shared.hasPremium else {
                return
            }
            if let root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                let presentOn: UIViewController?
                if root is SplashScreenViewController {
                    presentOn = root.presentedViewController ?? root.children.first
                } else {
                    presentOn = root
                }
                guard let presentOn else { return }
                showPaywall(presenting: presentOn)
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        enteredInBackground = true
    }
}

