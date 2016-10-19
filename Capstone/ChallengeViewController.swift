//
//  ChallengeViewController.swift
//  Capstone
//
//  Created by Satbir Tanda, Itzhak Koren on 7/19/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import UIKit
import MapKit

class ChallengeViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    let responseKey = "wayPoints"
    let storageAPI = StorageAPI()
    let serverAPI = ServerAPI(url: Routes.baseURL)
    let locationManager = CLLocationManager()
    var mapAPI: MapAPI?
    var flag = false
    var _id: String?
    
    @IBOutlet weak var opponentLabel: UILabel!
    @IBOutlet weak var opponentActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var routeLabel: UILabel!
    @IBOutlet weak var routeActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var startRaceButton: MaterialButton! {
        didSet {
            startRaceButton.enabled = false
        }
    }
    
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapAPI = MapAPI(mapView: mapView, flag: false)
        }
    }
    
    @IBOutlet weak var getOpponentButton: MaterialButton!
    private var currentlocation = Geolocation()
    
    var currentOpponent = "No Opponent" {
        didSet {
            if routePoints.count == 4 && currentOpponent != "No Opponent" {
                activateButton()
            }
        }
    }
    
    private var routePoints = [CLLocationCoordinate2D]() {
        didSet {
            if routePoints.count == 4 && currentOpponent != "No Opponent" {
                activateButton()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        locationManager.delegate = self
        mapView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        startRaceButton.enabled = false
        startRaceButton.backgroundColor = UIColor.flatGrayColor()
        if flag {
            setOpponent(currentOpponent)
        }
    }
    

    private func setupUI() {
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.flatWhiteColor()]   
    }
    
    @IBAction func getOpponentButtonTapped() {
        opponentActivityIndicator.startAnimating()
        serverAPI.getRequestTo(Routes.matchPath) { (success, result, err) in
            self.opponentActivityIndicator.stopAnimating()
            if success {
                // print("Result from tap -> \(result)")
                if result != nil {
                    if let opponentName = result!["username"] as? String {
                        if let opponentRank = result!["rank"] as? Int {
                            self.currentOpponent = opponentName
                            self.opponentLabel.text = "\(opponentName), Rank: \(opponentRank)"

                        }
                    }
                }
            } else {
                print("Error -> \(err)")
            }
        }
    }

    @IBAction func getRouteButtonTapped() {
        checkLocationAuthorizationStatus()
    }

    @IBAction func startRaceButtonTapped() {
         // present view controller
    }
    
    
    /* MapKit Private Methods */
    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse ||  CLLocationManager.authorizationStatus() == .AuthorizedAlways {
            getRoute()
        } else if CLLocationManager.authorizationStatus() == .NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        } else {
            SweetAlert().showAlert("Enable Location Sevices", subTitle: "Please enable location services in the Settings App to start your race!", style: .None, buttonTitle: "Settings", buttonColor: UIColor.flatBlueColor(), otherButtonTitle: "Cancel", otherButtonColor: UIColor.flatBlueColor(), action: { (isOtherButton) in
                if isOtherButton {
                    if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.sharedApplication().openURL(settingsURL)
                    }
                }
            })
        }
        
    }
    
    private func updateLocation() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    /* MapKit Delegation */
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse || status == .AuthorizedAlways {
            updateLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locValue = manager.location?.coordinate {
            // print("locations = \(locValue.latitude) \(locValue.longitude)")
            
            let latitude:CLLocationDegrees = locValue.latitude //insert latitutde
            
            let longitude:CLLocationDegrees = locValue.longitude //insert longitude
            
            currentlocation.latitude = Double(latitude)
            currentlocation.longitude = Double(longitude)
            
            mapView.setUserTrackingMode( .Follow, animated: true)
            
        }
    }
    
    private func getRoute() {
        routePoints.removeAll()
        mapAPI?.clearRoutePoints()
        self.routeActivityIndicator.startAnimating()
        let request = ["length": 3000, "origin": ["lat": currentlocation.latitude, "lng": currentlocation.longitude]]
        serverAPI.postRequestTo(Routes.routePath, withRequest: request) { (success, response, error) in
            if(success) {
                if response != nil {
                    // print("Response -> \(response!)")
                    self.routeLabel.text = "Route Set!"
                    self.SetRoute(response!)
                }
            } else {
                print("Error -> \(error)")
                self.routeLabel.text = "No Route"
            }
            self.routeActivityIndicator.stopAnimating()
        }
    }
    
    private func activateButton() {
        startRaceButton.enabled = true
        // startRaceButton.backgroundColor = UIColor.flatRedColor()
        UIView.animateWithDuration(1.0,
                                   delay: 0,
                                   options:  [.AllowUserInteraction, .Repeat],
                                   animations: {
                                        self.startRaceButton.backgroundColor = UIColor.flatRedColor()
                                    },
                                   completion: nil)
    }
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
        if let identifier = segue.identifier {
            if identifier == "RaceSegue" {
                if let urvc = segue.destinationViewController as? UserRunViewController {
                    urvc.wayPoints = routePoints
                    urvc.length = 3000
                    if let username = storageAPI.getUsername() {
                        urvc.username = username
                    }
                    urvc.opponentUsername = currentOpponent
                    urvc._id = _id
                }
            }
        }
     }
    
    func setOpponent(opponent: String) {
        currentOpponent = opponent
        getOpponentButton?.enabled = false
        opponentLabel?.text = opponent
        getOpponentButton.backgroundColor = UIColor.flatGrayColor()
    }

    
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private func SetRoute(request: [String: AnyObject]){
        routePoints.removeAll()
        mapAPI?.clearRoutePoints()
        var coord = [Geolocation]()
        coord.append(Geolocation(latitude: currentlocation.latitude, longitude: currentlocation.longitude))

        if let points = request[responseKey] as? [[String: AnyObject]] {
            for i in 0 ..< points.count {
                if let lat = points[i]["lat"] as? Double {
                    if let lng = points[i]["lng"] as? Double {
                        // print("latitude: \(lat)")
                        // print("longitude: \(lng)")
                        coord.append(Geolocation(latitude: lat, longitude: lng))
                    }
                }
            }
        }

        for i in 0...3 {
            let point = coord[i]
            routePoints.append(CLLocationCoordinate2DMake(point.latitude,point.longitude))
        }
        mapAPI?.routePoints = self.routePoints
    }
    
    
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polyShow = MKPolylineRenderer(overlay: overlay)
        polyShow.strokeColor = UIColor.blueColor()
        polyShow.lineWidth = 2
        return polyShow
    }
    
}

struct Geolocation {
    var latitude: Double = 0
    var longitude: Double = 0
}

