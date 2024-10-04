//
//  TabBarViewController.swift
//  Screen-Mirroring
//
//  Created by Denis Borodavchenko on 29.09.24.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let newViewController = TVControlViewWrapper.createTVRemoteView()
        let nc = UINavigationController(rootViewController: newViewController)
        newViewController.tabBarItem = UITabBarItem(title: "TV Remote", image: R.image.tv(), tag: 0)
        
        var viewControllers = self.viewControllers ?? []
        viewControllers.insert(nc, at: 0)
        self.viewControllers = viewControllers
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
