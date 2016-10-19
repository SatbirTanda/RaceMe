//
//  RaceMeTabBarViewController.swift
//  Capstone
//
//  Created by Satbir Tanda on 7/9/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit
import MapKit

class RaceMeTabBarViewController: UITabBarController, HealthAPIDelegate {

    let healthAPI = HealthAPI()
    let serverAPI = ServerAPI(url: Routes.baseURL)

    override func viewDidLoad() {
        super.viewDidLoad()
        healthAPI.delegate = self
        // Do any additional setup after loading the view.v
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // ask for location
        healthAPI.authorizeHealthKit() {
            self.healthAPI.update()
        }
    }

    /* Health API Delegate */
    
    func healthDataDidGetQueried() {
        self.postHealthData()
    }
    
    /* Private Helpers */
    private func postHealthData() {
        let request: [String: AnyObject] = ["totalSteps": healthAPI.totalSteps,
                                            "totalFlights": healthAPI.totalFlights,
                                            "totalWalkRunDistance": healthAPI.totalWalkRunDistance,
                                            "incrementsOfStepsForEachDay": healthAPI.incrementsOfStepsForEachDay,
                                            "incrementsOfFlightsForEachDay": healthAPI.incrementsOfFlightsForEachDay, "incrementsOfWalkRunDistanceForEachDay": healthAPI.incrementsOfWalkRunDistanceForEachDay,
                                            "totalStepsForEachDayOfYear": healthAPI.totalStepsForEachDayOfYear,
                                            "totalFlightsForEachDayOfYear": healthAPI.totalFlightsForEachDayOfYear,
                                            "totalWalkRunDistanceForEachDayOfYear": healthAPI.totalWalkRunDistanceForEachDayOfYear,
                                            "biologicalSex": healthAPI.biologicalSex,
                                            "bloodType": healthAPI.bloodType]
        serverAPI.postRequestTo(Routes.healthPath, withRequest: request) { (success, response, err) in
//            let appearance = SCLAlertView.SCLAppearance( showCloseButton: true )
//            let alertView = SCLAlertView()
//            alertView.appearance = appearance
            if success {
                // alertView.showSuccess("Success!", subTitle: "Health data sent!")
                SweetAlert().showAlert("Success!", subTitle: "Health data sent!", style: .Success, buttonTitle: "Ok", buttonColor: UIColor.flatGreenColor(), action: nil)
            } else {
               // alertView.showError("Error!", subTitle: err)
                SweetAlert().showAlert("Error!", subTitle: err, style: .Error, buttonTitle: "Ok", buttonColor: UIColor.flatRedColor(), action: nil)
            }
        }
    }
    
}
