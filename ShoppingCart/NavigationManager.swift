//
//  NavigationManager.swift
//  ShoppingCart
//
//  Created by IITC-MACBOOK02 on 09/03/17.
//  Copyright © 2017 Intelegencia. All rights reserved.
//

import UIKit

class NavigationManager: NSObject {

    static func pushToCart() {
        let cart = CartViewController.cartView()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.navigationController?.pushViewController(cart, animated: true)
    }
}
