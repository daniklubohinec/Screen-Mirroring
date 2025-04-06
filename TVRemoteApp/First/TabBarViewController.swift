import UIKit

final class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let newViewController = TVControlViewWrapper.createTVRemoteView()
        let nc = UINavigationController(rootViewController: newViewController)
        newViewController.tabBarItem = UITabBarItem(title: "TV Remote", image: R.image.tabs.tv(), tag: 0)
        
        var viewControllers = self.viewControllers ?? []
        viewControllers.insert(nc, at: 0)
        self.viewControllers = viewControllers
    }
}
