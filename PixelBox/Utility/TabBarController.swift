//
//  TabBarController.swift
//  PixelBox
//
//  Created by Justin Madewell on 8/20/18.
//  Copyright © 2018 Jmade Technologies. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pixelVC = PixelViewController()
        
        pixelVC.tabBarItem =
            UITabBarItem(title: "Pixels", image: #imageLiteral(resourceName: "pixels"), tag: 0)
        
        let otherVC = UINavigationController(rootViewController: OtherViewController())
        otherVC.tabBarItem = UITabBarItem(title: "Saved", image: #imageLiteral(resourceName: "rpi"), tag: 1)
        
        let tabBarList = [pixelVC, otherVC]
        
        viewControllers = tabBarList
    }

}
