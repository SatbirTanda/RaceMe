//
//  ViewController.swift
//  RunningSpeed
//
//  Created by iZahi on 7/8/16.
//  Copyright © 2016 iZahi. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class UserRunViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

   

    var runnerGeoManager = CLLocationManager()
    lazy var runnerSpeed = 0.0
    lazy var runnerSpeedArray = [Double]()
    var runnerDistance = 0.0
    lazy var runnerLocations = [CLLocation]()
    //var wayPoints = [CLLocationCoordinate2D]()
    //distinct between the two polylines on the map.
    var routeFromServerLayer = MKPolyline()
    var routeFromRunnerOnMap = MKPolyline()
    let serverAPI = ServerAPI(url: Routes.baseURL)
    var avgSpeed = 0.0

    
    var startTime: Double = 0
    var endTime: Double = 0
    var length = 0
    var username = ""
    var opponentUsername = ""
    var wayPoints =  [CLLocationCoordinate2D]()
    
    var _id: String?
    
    struct Geolocation{
        var altitude: Double
        var longitude: Double
        init(){
            altitude = 0.0
            longitude = 0.0
        }
    }
    //Draw polyline
//    func SetRoute(){
//        var coord = [Geolocation]()
//        var x1 = Geolocation()
//        var x2 = Geolocation()
//        var x3 = Geolocation()
//        var x4 = Geolocation()
//        var x5 = Geolocation()
//        x1.altitude = 40.7570088
//        x1.longitude = -73.82442249999997
//        x2.altitude = 40.7711632
//        x2.longitude = -73.83152749999999
//        x3.altitude = 40.7737825
//        x3.longitude = -73.82208029999999
//        x4.altitude = 40.7598609
//        x4.longitude = -73.81485270000002
//        x5.altitude = 40.7570088
//        x5.longitude = -73.82442249999997
//        coord = [x1,x2,x3,x4,x5]
//        for i in 0...4{
//            let point = coord[i]
//            wayPoints.append(CLLocationCoordinate2DMake(point.altitude,point.longitude))
//        }
//    }
    
override func viewDidLoad() {
        startTime = Double(NSDate().timeIntervalSince1970)

        print("Username: \(username), OpponentNmae: \(opponentUsername), route: \(wayPoints), length: \(length)")
//        SetButtonBorders(StopButton)
//        SetButtonBorders(RunButton)
//        SetViewButtonBorders(RunnderTime)
//        SetViewButtonBorders(RunnderSpeed)
//        SetViewButtonBorders(RunnderDistance)
        super.viewDidLoad()
        // self.view.backgroundColor = UIColor(patternImage: UIImage(named: "IMG_0265.png")!)
        runnerGeoManager.delegate = self
        RunnerMap.delegate = self
        BuildRoute()
        RunnerMap.zoomEnabled = true
        RunnerMap.scrollEnabled = true
        runnerGeoManager.requestWhenInUseAuthorization()
        if  CLLocationManager.locationServicesEnabled(){
            //Highest Accuracy level - check Battery performance
            runnerGeoManager.desiredAccuracy = kCLLocationAccuracyBest
            runnerGeoManager.distanceFilter = 10
            runnerGeoManager.activityType = CLActivityType.Fitness
            //start timer - check on  a phone to see if one timer affect the other.
            time = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(RunTimer), userInfo: nil, repeats: true)
            refreshDistance =  NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
            //RunnderDistance.text = "\(runnerDistance)"
            runnerGeoManager.startUpdatingLocation()
            RunnerMap.setUserTrackingMode( .Follow, animated: true)
        }
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolyline{
            if overlay as? MKPolyline == routeFromRunnerOnMap{
            let polyShow = MKPolylineRenderer(overlay: overlay)
            polyShow.strokeColor = UIColor.blueColor()
            polyShow.lineWidth = 10
            return polyShow
            }
            else if overlay as? MKPolyline == routeFromServerLayer{
                let polyShow = MKPolylineRenderer(overlay: overlay)
                polyShow.strokeColor = UIColor.blackColor()
                polyShow.lineWidth = 2
                return polyShow
            }
        }
        return nil
    }
    //Clear Screen
    func ClearScreenFromOverlays(){
        let presentOverlays = self.RunnerMap.overlays
        self.RunnerMap.removeOverlays(presentOverlays)
    }
    
   func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //update locations array, distance.
        for location in locations{
                if self.runnerLocations.count > 0 {
                    self.runnerDistance = runnerDistance + location.distanceFromLocation(self.runnerLocations.last!)
                    //Meters
                    self.runnerDistance = (round(runnerDistance))
                }
                self.runnerLocations.append(location)
           // }
        }
        //KM/H
        self.runnerSpeed = (round(10 * (runnerGeoManager.location!.speed * 3.6)) / 10)
        self.runnerSpeedArray.append(runnerSpeed)
        //Set runner region view
        //RunnerMap.setRegion(MKCoordinateRegionMake(RunnerMap.userLocation.coordinate, MKCoordinateSpanMake(0.05, 0.05)), animated: true)
        //RunnerMap.setUserTrackingMode( .Follow, animated: true)

    }
    //User for diaplying user polyline
    //polyline between new and old location.
    func locationManager(manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
        let old = oldLocation.coordinate
        let new = newLocation.coordinate
        var twoPoints = [old, new]
        //print(twoPoints)
        let runnerPolyline = MKPolyline(coordinates: &twoPoints , count: twoPoints.count)
        self.routeFromRunnerOnMap = runnerPolyline
        RunnerMap.addOverlay(runnerPolyline)
    }

    @IBOutlet weak var RunnerMap: MKMapView!
    
    @IBOutlet weak var RunnderTime: UILabel!
    
    @IBOutlet weak var RunnderDistance: UILabel!
    
    @IBOutlet weak var RunnderSpeed: UILabel!
    
    @IBOutlet weak var StopButton: UIButton!
    
    @IBOutlet weak var RunButton: UIButton!
    

    
    ////////////
    private var count = 0
    private var seconds = 0
    private var minutes = 0
    private var hours = 0
    private var time = NSTimer()
    private var refreshDistance = NSTimer()
    
    func RunTimer(){
        count += 1
        if count % 60 == 0{
            seconds = 0
            minutes = count/60
        }
        else{
            seconds = count%60
        }
        if (count == 3600){
            count = 0
            minutes = 0
            hours += 1
        }
        if (seconds < 10) && (minutes > 9) && (hours < 10){
            RunnderTime.text = "Time-0\(hours):\(minutes):0\(seconds)"
        }
        else if (seconds < 10) && (minutes > 9) && (hours > 9){
            RunnderTime.text = "Time-\(hours):\(minutes):0\(seconds)"
        }
        else if (seconds < 10) && (minutes < 10){
            RunnderTime.text = "Time-0\(hours):0\(minutes):0\(seconds)"
        }
        else if (seconds > 9) && (minutes < 10){
            RunnderTime.text = "Time-0\(hours):0\(minutes):\(seconds)"
        }
        else{
                RunnderTime.text = "Time-0\(hours):\(minutes):\(seconds)"
        }
    }
    //////
    
    func updateData(){
        RunnderDistance.text = "Distance-" + String(runnerDistance / 1000.0)
        RunnderSpeed.text = "Speed-\(runnerSpeed)"
    }
    
    private func SetButtonBorders(button: UIButton){
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blackColor().CGColor
        button.layer.backgroundColor = UIColor.purpleColor().CGColor
    }
    
    private func SetViewButtonBorders(view: UIView){
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.blackColor().CGColor
        view.layer.backgroundColor = UIColor.purpleColor().CGColor
    }
    
     func StartRace() {
        //start timer - check on  a phone to see if one timer affect the other.
        time = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(RunTimer), userInfo: nil, repeats: true)
        refreshDistance =  NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
        //RunnderDistance.text = "\(runnerDistance)"
        runnerGeoManager.startUpdatingLocation()
        }
        
    @IBAction func StopRunTime() {
        endTime = Double(NSDate().timeIntervalSince1970)
        time.invalidate()
        runnerGeoManager.stopUpdatingLocation()
        //ClearScreenFromOverlays()
        //SendData(runnerSpeed,RunnerDistance,RunnerTime)
        let divide = runnerSpeedArray.count
        var sum = 0.0
        for x in runnerSpeedArray{
            sum += x
            print(x)
        }
        avgSpeed = sum / Double(divide)
        print(runnerDistance)
        runnerLocations.removeAll()
        runnerSpeedArray.removeAll()
//        runnerSpeed = 0.0
//        runnerDistance = 0.0
//        count = 0
        self.dismissViewControllerAnimated(true) {
            if let id = self._id {
                let request: [String: AnyObject] = ["start": self.startTime,
                                                    "end": self.endTime,
                                                    "speed": self.avgSpeed,
                                                    "route": [
                                                        "origin": ["lat": self.wayPoints[0].latitude, "lng": self.wayPoints[0].longitude ],
                                                        "wayPoints": [
                                                            ["lat": self.wayPoints[1].latitude, "lng": self.wayPoints[1].longitude],
                                                            ["lat": self.wayPoints[2].latitude, "lng": self.wayPoints[2].longitude],
                                                            ["lat": self.wayPoints[3].latitude, "lng": self.wayPoints[3].longitude]
                                                        ]
                                                        ]
                                                    ]
                self.serverAPI.postRequestTo(Routes.racePath, withRequest: request, withHeader: "Race-Id", withHeaderValue: id, completionHandler: { (success, response, error) in
                    if success {
                        if response != nil {
                            print("Race ID response -> \(response!)")
                        }
                    } else {
                        print(error)
                    }
                })
            } else {
                let request: [String: AnyObject] =
                    ["challenger":
                        ["start": self.startTime,
                            "end": self.endTime,
                            "duration": self.endTime - self.startTime,
                            "speed": self.avgSpeed,
                            "route": [
                                "origin": ["lat": self.wayPoints[0].latitude, "lng": self.wayPoints[0].longitude ],
                                "wayPoints": [
                                    ["lat": self.wayPoints[1].latitude, "lng": self.wayPoints[1].longitude],
                                    ["lat": self.wayPoints[2].latitude, "lng": self.wayPoints[2].longitude],
                                    ["lat": self.wayPoints[3].latitude, "lng": self.wayPoints[3].longitude]
                                ]
                            ]
                        ],
                     "opponent": ["username": self.opponentUsername]
                ]
                self.serverAPI.postRequestTo(Routes.racePath, withRequest: request, completionHandler: { (success, response, error) in
                    if success {
                        if response != nil {
                            print("Race response -> \(response!)")
                        }
                    } else {
                        print(error)
                    }
                })

            }
            //            print("Username: \(self.username), OpponentNmae: \(self.opponentUsername), route: \(self.wayPoints), length: \(self.length)")
        }
    }
            
    
    //Use the source: https://www.hackingwithswift.com/example-code/location/how-to-find-directions-using-mkmapview-and-mkdirectionsrequest
    func BuildRoute(){
        
        let getHereAndThere = MKDirectionsRequest()
        
        getHereAndThere.transportType = MKDirectionsTransportType.Walking
        
        wayPoints.insert(wayPoints[3], atIndex: 0)
        
        for i in 0...3 {
            
            getHereAndThere.source = MKMapItem(placemark: MKPlacemark(coordinate: wayPoints[i], addressDictionary: nil))
            
            getHereAndThere.destination = MKMapItem(placemark: MKPlacemark(coordinate: wayPoints[i+1], addressDictionary: nil))
            
            let makeIT = MKDirections(request: getHereAndThere)
            
            makeIT.calculateDirectionsWithCompletionHandler{ [unowned self] response, error in
                
                guard let unwrappedResponse = response else {return}
                
                for route in unwrappedResponse.routes{
                    self.routeFromServerLayer = route.polyline
                    self.RunnerMap.addOverlay(route.polyline)
                    //self.RunnerMap.setVisibleMapRect(route.polyline.boundingMapRect, animated: false)
                    //print("\(route.distance)")
                    
                }
               
            }
            
        }
        

   
    
}
}


