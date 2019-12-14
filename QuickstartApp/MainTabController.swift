//
//  MainTabController.swift
//  QuickstartApp
//
//  Created by PRAE on 3/10/19.
//  Copyright © 2019 Yevgeniy Vasylenko. All rights reserved.
//

import Foundation
import UIKit;


protocol MainTabControllerDelegate {
    func logOutGoogle()
}
class MainTabController : UITabBarController {
    
    var delegate1 : MainTabControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Home"
        let logOutButton = UIBarButtonItem(
            title: "Log Out",
            style: .plain,
            target: self,
            action: #selector(leftButtonAction(sender:))
        )
        self.navigationItem.leftBarButtonItem = logOutButton
    }
    
    func leftButtonAction(sender: UIBarButtonItem) {
        self.delegate1?.logOutGoogle()
    }
}
