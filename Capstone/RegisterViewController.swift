//
//  ViewController.swift
//  Capstone
//
//  Created by Satbir Tanda on 6/14/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit
import ChameleonFramework

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    /* CONSTANTS */
    let serverAPI = ServerAPI(url: Routes.baseURL)
    var modUIUX: ModUIUX?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view, typically from a nib.
        modUIUX = ModUIUX(withViewController: self, indicator: activityIndicator)
        self.hideKeyboardWhenTappedAround()
        usernameTextField.delegate = self
        fullNameTextField.delegate = self
        passwordTextField.delegate = self
    }

    @IBAction func sendButton() {
        postToServer();
    }
    
    private func postToServer() {
        // print("posting");
        if let username = usernameTextField.text {
            if let password = passwordTextField.text {
                if let fullName = fullNameTextField.text {
                    let request = ["username": username, "fullname": fullName, "password": password]
                    modUIUX?.startSpinning()
                    serverAPI.postRequestTo(Routes.registerPath, withRequest: request, completionHandler: { (success, result, error) in
                        self.modUIUX?.stopSpinning()
                        if(success) {
                            self.modUIUX?.showSuccessAlert(withTitle: "Registration successful",
                                                            withMessage: "You may now login. Thank You!",
                                                            withButtonTitle: "Login",
                                                            buttonCompletion: { () in
                                                                    self.performSegueWithIdentifier(Segues.SignIn, sender:self)
                                                            },
                                                            presentationCompletion: nil)
                        }
                        else {
                            self.modUIUX?.showFailedAlert(withMessage: error)
                        }
                    });
                }
            }
        }
    }
    
    /* UITextfield Delegate Methods */
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.fullNameTextField {
            self.usernameTextField.becomeFirstResponder()
        } else if textField == self.usernameTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if self.passwordTextField.isFirstResponder() && self.usernameTextField.text != nil && self.fullNameTextField.text != nil {
            sendButton()
            textField.resignFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    private func setupUI() {
        view.backgroundColor = Colors.signatureColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Colors.barTextTintColor]
        registerButton.backgroundColor = Colors.barColor
    }
    
}

