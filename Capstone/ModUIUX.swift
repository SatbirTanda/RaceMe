//
//  ModUIUX.swift
//  Capstone
//
//  Created by Satbir Tanda on 7/1/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit
import Foundation
import ChameleonFramework

class ModUIUX {
    
    let vc: UIViewController!
    var indicator: UIActivityIndicatorView!

    init(withViewController vc: UIViewController, indicator: UIActivityIndicatorView!) {
        self.vc = vc
        self.indicator = indicator
    }
    
    func showSuccessAlert(withTitle title: String, withMessage message: String, withButtonTitle buttonTitle: String, buttonCompletion: (() -> Void)?, presentationCompletion: (() -> Void)?) {

//        let appearance = SCLAlertView.SCLAppearance( showCloseButton: false )
//        let alertView = SCLAlertView()
//        alertView.appearance = appearance
//        alertView.addButton(buttonTitle) {
//            buttonCompletion?()
//        }
//        alertView.showSuccess(title, subTitle: message)
        SweetAlert().showAlert(title, subTitle: message, style: .Success, buttonTitle: "OK", buttonColor: UIColor.flatGreenColor()) { (isOtherButton) in
            buttonCompletion?()
        }
 
    }
    
    func showFailedAlert(withMessage message: String) {
//        var bodyMessage = message
//        if bodyMessage == "" { bodyMessage = "Something went wrong." }
//        SCLAlertView().showError("An error occurred", subTitle: message)
          SweetAlert().showAlert("Error!", subTitle: message, style: .Error, buttonTitle: "OK", buttonColor: UIColor.flatRedColor(), action: nil)
    }
    
//    func showWaitingAlert(title: String, message: String) {
//        let appearance = SCLAlertView.SCLAppearance( showCloseButton: false )
//        let alertView = SCLAlertView()
//        alertView.appearance = appearance
//    }
//    
    
    
    func startSpinning() {
        indicator?.hidden = false
        indicator?.startAnimating()
    }
    
    func stopSpinning() {
        indicator?.hidden = true
        indicator?.stopAnimating()
    }
    
}

struct Colors {
    static let barTextTintColor = UIColor.flatWhiteColor()
    static let barColor = UIColor.flatGreenColor()
    static let signatureColor = GradientColor(.LeftToRight, frame: UIScreen.mainScreen().bounds, colors: [UIColor.flatOrangeColor(), UIColor.flatRedColor()])
}

struct Animations {
    static let cameraIris = "cameraIris"
    static let cameraIrisHollowOpen = "cameraIrisHollowOpen"
    static let cameraIrisHollowClose = "cameraIrisHollowClose"
    static let cube = "cube"
    static let flip = "flip"
    static let rotate = "rotate"
    static let rippleEffect = "rippleEffect"
    static let pageUnCurl = "pageUnCurl"
    static let pageCurl = "pageCurl"
}

struct Segues {
    static let SignIn = "SegueToSignIn"
}

struct StoryBoards {
    static let Main = "Main"
    static let LoginRegister = "LoginRegister"
}