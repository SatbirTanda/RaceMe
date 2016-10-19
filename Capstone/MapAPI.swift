//
//  MapAPI.swift
//  Capstone
//
//  Created by Satbir Tanda on 7/30/16.
//  Copyright © 2016 Satbir Tanda. All rights reserved.
//

import Foundation
import MapKit

class MapAPI {

    let mapView: MKMapView!
    var flag = false
    
    var routePoints = [CLLocationCoordinate2D]() {
        didSet {
            if routePoints.count == 4 {
                BuildRoute()
            }
        }
    }
    
    init(mapView: MKMapView, flag: Bool)  {
        self.mapView = mapView
        self.flag = flag
    }
    
    /*
     Use the source: https:www.hackingwithswift.com/example-code/location/how-to-find-directions-using-mkmapview-and-mkdirectionsrequest
     */
    
    
    private func BuildRoute(){
        
        ClearScreenOfOverlays()
        
        let getHereAndThere = MKDirectionsRequest()
        
        getHereAndThere.transportType = MKDirectionsTransportType.Walking
        
        for i in 0...2 {

            getHereAndThere.source = MKMapItem(placemark: MKPlacemark(coordinate: self.routePoints[i], addressDictionary: nil))
            
            if i < 2 {
                getHereAndThere.destination = MKMapItem(placemark: MKPlacemark(coordinate: routePoints[i+1], addressDictionary: nil))
            } else {
                getHereAndThere.destination = MKMapItem(placemark: MKPlacemark(coordinate: routePoints[0], addressDictionary: nil))
            }
            
            
            let makeIT = MKDirections(request: getHereAndThere)
            
            makeIT.calculateDirectionsWithCompletionHandler{ [unowned self] response, error in
                
                guard let unwrappedResponse = response else {return}
                
                for route in unwrappedResponse.routes {
                    
                    self.mapView.addOverlay(route.polyline)
                    
                    if self.flag {
                        if route == unwrappedResponse.routes.last {
                            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                        
                    }

                }
                
            }
            
        }
    }
    
    //Clear Screen
    private func ClearScreenOfOverlays(){
        let presentOverlays = self.mapView.overlays
        self.mapView.removeOverlays(presentOverlays)
    }
    
    func clearRoutePoints() {
        routePoints = [CLLocationCoordinate2D]()
    }
}