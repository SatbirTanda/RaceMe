//
//  UserViewController.swift
//  Capstone
//
//  Created by Satbir Tanda on 7/1/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    let storageAPI = StorageAPI()
    let serverAPI = ServerAPI(url: Routes.baseURL)
    var modUIUX: ModUIUX?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        modUIUX = ModUIUX(withViewController: self, indicator: nil)
    }

    @IBAction func logoutButtonTapped(sender: AnyObject) {
        logout()
    }
    
    private func logout() {
        storageAPI.removeToken()
        if let delegate = UIApplication.sharedApplication().delegate {
            // delegate.window!!.rootViewController = UIStoryboard(name: StoryBoards.LoginRegister , bundle: NSBundle.mainBundle()).instantiateInitialViewController()
            let transition = CATransition()
            transition.type = Animations.cube
            transition.subtype = kCATransitionFromRight
            delegate.window!!.setRootViewController(UIStoryboard(name: StoryBoards.LoginRegister , bundle: NSBundle.mainBundle()).instantiateInitialViewController()!, transition: transition)
        }
    }
    
    private func setupUI() {
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.flatWhiteColor()]
        if let token = storageAPI.getToken() {
            if let userDataString = JWT.decodeJWT(token) {
                // print("User Data -> \(userDataString)")
                if let userInfo = JWT.convertStringToDictionary(userDataString) {
                    if let fullname = userInfo["fullname"] as? String {
                        self.navigationItem.title = "Hello, \(fullname)"
                    }
                }
            }
        }
    }
    
}
