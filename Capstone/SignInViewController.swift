//
//  SignInViewController.swift
//  Capstone
//
//  Created by Satbir Tanda on 6/16/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit
import HealthKit
import ChameleonFramework

class SignInViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var racemeLabel: UILabel!
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var username: String?
    var password: String?
    var modUIUX: ModUIUX?
    
    /* CONSTANTS */
    let serverAPI = ServerAPI(url: Routes.baseURL)
    let storageAPI = StorageAPI()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
        modUIUX = ModUIUX(withViewController: self, indicator: activityIndicator)
        self.hideKeyboardWhenTappedAround()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        if (username != nil) && (password != nil) {
            usernameTextField.text = username
            passwordTextField.text = password
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animationOpening()
    }
    
    override func viewDidDisappear(animated: Bool) {
        racemeLabel.alpha = 0.0
        containerView.alpha = 0.0
    }
    
    @IBAction func signInButtonPressed() {
        signIn()
    }

    private func signIn() {
        if let username = usernameTextField.text {
            if let password = passwordTextField.text {
                let request = ["username": username, "password": password]
                modUIUX?.startSpinning()
                self.loginRequest(request)
            }
        }
    }
    
    private func loginRequest(request: [String: AnyObject]) {
        serverAPI.postRequestTo(Routes.loginPath, withRequest: request, completionHandler: { (success, result, error) in
            self.modUIUX?.stopSpinning()
            if (success) {
                if let token = JWT.getJWT(result) {
                    self.storageAPI.saveToken(token)
                    // print("token -> \(token)")
                    // segue to app
                    if let delegate = UIApplication.sharedApplication().delegate {
                        //delegate.window!!.rootViewController = UIStoryboard(name: StoryBoards.Main , bundle: NSBundle.mainBundle()).instantiateInitialViewController()
                            let transition = CATransition()
                            transition.type = Animations.cube
                            transition.subtype = kCATransitionFromRight
                            delegate.window!!.setRootViewController(UIStoryboard(name: StoryBoards.Main , bundle: NSBundle.mainBundle()).instantiateInitialViewController()!, transition: transition)
                    }
                }
            } else {
                self.modUIUX?.showFailedAlert(withMessage: error)
            }
        })
    }
    
    /* UITextfield Delegate Methods */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if self.passwordTextField.isFirstResponder() && usernameTextField.text != nil {
            signIn()
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder() 
        }
        return true
    }
    
    /* NAVIGATION */
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        // print("Unwinded")
        if segue.identifier == Segues.SignIn {
            if let rvc = segue.sourceViewController as? RegisterViewController {
                if let username = rvc.usernameTextField.text {
                    if let password = rvc.passwordTextField.text {
                        // print("un: \(username), pw: \(password)")
                        self.usernameTextField.text = username
                        self.passwordTextField.text = password
                    }
                }
            }
        }
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.signatureColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.barTextTintColor]
        signInButton.backgroundColor = UIColor.flatGreenColor()
        registerButton.backgroundColor = UIColor.flatBlueColor()
    }
    
    private func animationOpening() {
        racemeLabel.alpha = 0.0
        containerView.alpha = 0.0
        let fakeRacemeLabel = UILabel()
        fakeRacemeLabel.text = "RaceMe"
        fakeRacemeLabel.font = UIFont(name: "GurmukhiMN-Bold", size: 60)
        fakeRacemeLabel.textColor = UIColor.flatWhiteColor()
        fakeRacemeLabel.sizeToFit()
        fakeRacemeLabel.frame = CGRect(x: CGRectGetMidX(view.frame) - fakeRacemeLabel.frame.width/2.0, y: CGRectGetMidY(view.frame) - fakeRacemeLabel.frame.height/2.0, width: fakeRacemeLabel.frame.width, height: fakeRacemeLabel.frame.height)
        fakeRacemeLabel.alpha = 0.0
        view.addSubview(fakeRacemeLabel)
        UIView.animateWithDuration(0.5, delay: 0.0, options: .AllowUserInteraction, animations: { 
            fakeRacemeLabel.alpha = 1.0
            }) { (success) in
                if success {
                    UIView.animateWithDuration(1.0, delay: 0.0, options: .AllowUserInteraction, animations: {
                        fakeRacemeLabel.frame = CGRect(x: CGRectGetMidX(self.view.frame) - fakeRacemeLabel.frame.width/2.0, y: CGRectGetMidY(self.view.frame) - 4*fakeRacemeLabel.frame.height, width: fakeRacemeLabel.frame.width, height: fakeRacemeLabel.frame.height)
                        fakeRacemeLabel.alpha = 0.0
                    }) { (success) in
                        if success {
                            fakeRacemeLabel.removeFromSuperview()
                            UIView.animateWithDuration(1.0, animations: {
                                self.racemeLabel.alpha = 1.0
                                self.containerView.alpha = 1.0
                            })
                        }
                    }
                }
        }
    }
    

}
